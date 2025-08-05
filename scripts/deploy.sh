#!/bin/bash

# ===========================================
# SURGE DEPLOYMENT SCRIPT
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print banner
print_banner() {
    echo ""
    echo -e "${BLUE}"
    echo "  ███████╗██╗   ██╗██████╗  ██████╗ ███████╗"
    echo "  ██╔════╝██║   ██║██╔══██╗██╔════╝ ██╔════╝"
    echo "  ███████╗██║   ██║██████╔╝██║  ███╗█████╗  "
    echo "  ╚════██║██║   ██║██╔══██╗██║   ██║██╔══╝  "
    echo "  ███████║╚██████╔╝██║  ██║╚██████╔╝███████╗"
    echo "  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo "  Unified Media Management Stack"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose v2."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

# Create environment file
setup_environment() {
    print_info "Setting up environment..."
    
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        if [ -f "$PROJECT_DIR/.env.example" ]; then
            cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
            print_success "Created .env file from template"
            print_warning "Please edit .env file to customize your setup"
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_info ".env file already exists"
    fi
}

# Create directory structure
create_directories() {
    print_info "Creating directory structure..."
    
    # Read DATA_ROOT from .env or use default
    DATA_ROOT=$(grep "^DATA_ROOT=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "/opt/surge")
    
    mkdir -p "$DATA_ROOT"/{media/{movies,tv,music},downloads,config,logs}
    
    # Ensure logs directory exists for post-deployment logging
    mkdir -p "$PROJECT_DIR/logs"
    
    # Fix ownership for all directories (1000:1000 matches PUID:PGID used in containers)
    print_info "Setting proper ownership for storage directories..."
    if [ "$(id -u)" -eq 0 ]; then
        # Running as root, set ownership directly
        chown -R 1000:1000 "$DATA_ROOT"
        print_success "Directory ownership set to 1000:1000"
    else
        # Not running as root, use sudo
        if sudo -n true 2>/dev/null; then
            # Sudo available without password prompt
            sudo chown -R 1000:1000 "$DATA_ROOT"
            print_success "Directory ownership set to 1000:1000 (with sudo)"
        else
            # Prompt for sudo
            print_warning "Setting directory ownership requires sudo privileges..."
            if sudo chown -R 1000:1000 "$DATA_ROOT"; then
                print_success "Directory ownership set to 1000:1000 (with sudo)"
            else
                print_warning "Failed to set directory ownership. You may need to run manually:"
                print_warning "  sudo chown -R 1000:1000 $DATA_ROOT"
            fi
        fi
    fi
    
    print_success "Directory structure created at $DATA_ROOT"
}

# Show usage
show_usage() {
    echo "Usage: $0 [MEDIA_SERVER] [OPTIONS]"
    echo ""
    echo "Media Servers:"
    echo "  plex      - Deploy with Plex Media Server"
    echo "  emby      - Deploy with Emby Server"
    echo "  jellyfin  - Deploy with Jellyfin Server"
    echo ""
    echo "Options:"
    echo "  --minimal     - Deploy only core services"
    echo "  --full        - Deploy all services (default)"
    echo "  --update      - Update all containers to latest versions"
    echo "  --stop        - Stop all services"
    echo "  --restart     - Restart all services"
    echo "  --logs        - Show logs for all services"
    echo "  --status      - Show status of all services"
    echo "  -h, --help    - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 plex              # Deploy with Plex"
    echo "  $0 jellyfin --minimal # Deploy Jellyfin with minimal services"
    echo "  $0 --update          # Update all containers"
    echo "  $0 --status          # Show service status"
}

# Deploy services
deploy_services() {
    local media_server=$1
    local deployment_type=${2:-full}
    
    print_info "Deploying Surge with $media_server media server..."
    
    cd "$PROJECT_DIR"
    
    # Base compose files
    COMPOSE_FILES="-f docker-compose.yml"
    
    # Add media server specific compose file
    case $media_server in
        plex)
            COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.plex.yml"
            ;;
        emby)
            COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.emby.yml"
            ;;
        jellyfin)
            COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.jellyfin.yml"
            ;;
        *)
            print_error "Unknown media server: $media_server"
            exit 1
            ;;
    esac
    
    # Add automation if enabled
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.automation.yml"
    
    # Set profiles based on deployment type
    if [ "$deployment_type" = "minimal" ]; then
        export COMPOSE_PROFILES="$media_server,homepage"
    else
        export COMPOSE_PROFILES="$media_server,bazarr,imagemaid,nzbget,kometa,posterizarr,tautulli,homepage,scanly,gaps,cinesync"
    fi
    
    # Deploy
    print_info "Starting deployment with profiles: $COMPOSE_PROFILES"
    docker compose $COMPOSE_FILES up -d
    
    print_success "Surge deployed successfully!"
    
    # Configure services automatically
    configure_services
    
    # Run post-deployment configuration (in background to not block)
    print_info "Starting post-deployment configuration in background..."
    if [ -f "$SCRIPT_DIR/post-deploy-config.sh" ]; then
        nohup bash "$SCRIPT_DIR/post-deploy-config.sh" > "$PROJECT_DIR/logs/post-deploy.log" 2>&1 &
        print_info "Post-deployment configuration running in background. Check logs/post-deploy.log for progress."
    fi
    
    print_info "Access your services:"
    echo "  - Homepage Dashboard: http://localhost:3000"
    echo "  - CineSync Media Manager: http://localhost:8082"
    case $media_server in
        plex)
            echo "  - Plex Media Server: http://localhost:32400/web"
            ;;
        emby)
            echo "  - Emby Server: http://localhost:8096"
            ;;
        jellyfin)
            echo "  - Jellyfin Server: http://localhost:8096"
            ;;
    esac
}

# Configure services automatically
configure_services() {
    print_info "Configuring service connections automatically..."
    
    # Read STORAGE_PATH from .env file or use default
    STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
    export STORAGE_PATH
    
    # Generate CineSync configuration if CineSync is enabled
    if echo "$COMPOSE_PROFILES" | grep -q "cinesync"; then
        print_info "Generating CineSync configuration..."
        if "$SCRIPT_DIR/configure-cinesync.sh"; then
            print_success "CineSync configuration generated successfully!"
        else
            print_warning "Failed to generate CineSync configuration. You can run it manually:"
            print_warning "  $SCRIPT_DIR/configure-cinesync.sh"
        fi
    fi
    
    # Brief wait for containers to start writing config files
    print_info "Waiting for services to create configuration files..."
    sleep 30  # Increased wait time for better service initialization
    
    # Additional wait for API key generation
    print_info "Allowing extra time for API key generation..."
    sleep 15
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not found. Skipping automatic service configuration."
        print_info "You can manually configure services later by running:"
        print_info "  python3 -c 'from scripts.service_config import configure_prowlarr_applications; configure_prowlarr_applications()'"
        return
    fi
    
    # Configure Prowlarr applications (connect to Radarr and Sonarr)
    if docker compose ps prowlarr | grep -q "Up"; then
        print_info "Configuring Prowlarr applications..."
        if python3 -c "
import sys
sys.path.append('$SCRIPT_DIR')
from service_config import configure_prowlarr_applications
success = configure_prowlarr_applications()
sys.exit(0 if success else 1)
"; then
            print_success "Prowlarr applications configured successfully!"
        else
            print_warning "Failed to configure Prowlarr applications. You can try again manually:"
            print_warning "  python3 scripts/service_config.py"
            print_info "💡 This is normal for first-time deployments. Services need time to fully initialize."
            print_info "💡 Try running the configuration again in 5-10 minutes."
        fi
    else
        print_info "Prowlarr not running, skipping application configuration"
    fi
    
    # Configure Bazarr applications (connect to Radarr and Sonarr)  
    if docker compose ps bazarr | grep -q "Up"; then
        print_info "Configuring Bazarr applications..."
        if python3 -c "
import sys
sys.path.append('$SCRIPT_DIR')
from service_config import configure_bazarr_applications
success = configure_bazarr_applications()
sys.exit(0 if success else 1)
"; then
            print_success "Bazarr applications configured successfully!"
            print_info "💡 If Radarr/Sonarr don't appear in Bazarr settings, restart Bazarr:"
            print_info "💡 Go to http://localhost:6767 → Settings → General → Restart"
        else
            print_warning "Failed to configure Bazarr applications. You can try again manually:"
            print_warning "  python3 -c 'from scripts.service_config import configure_bazarr_applications; configure_bazarr_applications()'"
            print_info "💡 After configuration, restart Bazarr to pick up the new connections:"
            print_info "💡 You can restart Bazarr from its web interface or restart the deployment"
        fi
    else
        print_info "Bazarr not running, skipping application configuration"
    fi
    
    # Configure GAPS applications (connect to Radarr and Plex with TMDB)
    if docker compose ps gaps | grep -q "Up"; then
        print_info "Configuring GAPS applications..."
        if python3 -c "
import sys
sys.path.append('$SCRIPT_DIR')
from service_config import configure_gaps_applications
success = configure_gaps_applications()
sys.exit(0 if success else 1)
"; then
            print_success "GAPS applications configured successfully!"
            print_info "💡 GAPS is now accessible at http://localhost:8484"
            print_info "💡 The service is configured with your TMDB API key and Radarr connection"
            print_info "💡 Discord notifications will be enabled if webhook URL is configured"
        else
            print_warning "Failed to configure GAPS applications. You can try again manually:"
            print_warning "  python3 -c 'from scripts.service_config import configure_gaps_applications; configure_gaps_applications()'"
            print_info "💡 Make sure TMDB_API_KEY is set in your .env file"
            print_info "💡 GAPS requires this key to search for missing movies"
        fi
    else
        print_info "GAPS not running, skipping application configuration"
    fi
    
    # Configure Overseerr settings
    if docker compose ps overseerr | grep -q "Up" && [ -f "$SCRIPT_DIR/configure-overseerr.py" ]; then
        print_info "Configuring Overseerr settings..."
        if python3 "$SCRIPT_DIR/configure-overseerr.py"; then
            print_success "Overseerr settings configured successfully!"
        else
            print_warning "Failed to configure Overseerr settings"
        fi
    fi
    
    # Configure service API keys if needed (only if config files don't exist)
    if [ -f "$SCRIPT_DIR/inject-api-keys.py" ]; then
        # Check if API keys need to be generated (only for new installations)
        if [ ! -f "$STORAGE_PATH/Prowlarr/config/config.xml" ] || [ ! -f "$STORAGE_PATH/Radarr/config/config.xml" ] || [ ! -f "$STORAGE_PATH/Sonarr/config/config.xml" ]; then
            print_info "Generating initial API keys for new services..."
            if python3 "$SCRIPT_DIR/inject-api-keys.py" --generate-all --config-dir "$STORAGE_PATH" 2>/dev/null; then
                print_success "Initial API keys generated successfully!"
            else
                print_info "API keys will be generated automatically when services start"
            fi
        else
            print_info "API keys already exist, skipping generation"
        fi
    fi
    
    print_success "Service configuration completed!"
    
    print_success "Service configuration completed!"
}

# Update containers
update_containers() {
    print_info "Updating all containers..."
    cd "$PROJECT_DIR"
    docker compose pull
    docker compose up -d
    print_success "Containers updated successfully!"
}

# Stop services
stop_services() {
    print_info "Stopping all Surge services..."
    cd "$PROJECT_DIR"
    docker compose down
    print_success "All services stopped!"
}

# Restart services
restart_services() {
    print_info "Restarting all Surge services..."
    cd "$PROJECT_DIR"
    docker compose restart
    print_success "All services restarted!"
}

# Show logs
show_logs() {
    print_info "Showing logs for all services..."
    cd "$PROJECT_DIR"
    docker compose logs -f
}

# Show status
show_status() {
    print_info "Showing status of all services..."
    cd "$PROJECT_DIR"
    docker compose ps
}

# Main function
main() {
    print_banner
    
    # Parse arguments
    case ${1:-} in
        -h|--help)
            show_usage
            exit 0
            ;;
        --update)
            check_prerequisites
            update_containers
            exit 0
            ;;
        --stop)
            stop_services
            exit 0
            ;;
        --restart)
            restart_services
            exit 0
            ;;
        --logs)
            show_logs
            exit 0
            ;;
        --status)
            show_status
            exit 0
            ;;
        plex|emby|jellyfin)
            MEDIA_SERVER=$1
            DEPLOYMENT_TYPE="full"
            if [ "$2" = "--minimal" ]; then
                DEPLOYMENT_TYPE="minimal"
            fi
            ;;
        "")
            print_error "Media server not specified"
            show_usage
            exit 1
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
    
    # Run deployment
    check_prerequisites
    setup_environment
    create_directories
    deploy_services "$MEDIA_SERVER" "$DEPLOYMENT_TYPE"
}

# Run main function
main "$@"
