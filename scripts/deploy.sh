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
        export COMPOSE_PROFILES="$media_server,bazarr,nzbget,kometa,posterizarr,tautulli,homepage,scanly,watchtower,scheduler"
    fi
    
    # Deploy
    print_info "Starting deployment with profiles: $COMPOSE_PROFILES"
    docker compose $COMPOSE_FILES up -d
    
    print_success "Surge deployed successfully!"
    print_info "Access your services:"
    echo "  - Homepage Dashboard: http://localhost:3000"
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
