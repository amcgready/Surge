    # Dynamically generate Pangolin config
    if python3 "$SCRIPT_DIR/configure-pangolin.py" "$STORAGE_PATH"; then
        print_success "Pangolin config.json generated in $STORAGE_PATH/Pangolin/config/"
    else
        print_warning "Failed to generate Pangolin config.json. Please check configure-pangolin.py."
    fi
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

# Validate storage path configuration
validate_storage_path() {
    print_info "Validating storage path configuration..."
    
    if [ -f "$SCRIPT_DIR/validate-storage-path.sh" ]; then
        if ! "$SCRIPT_DIR/validate-storage-path.sh"; then
            print_error "Storage path validation failed!"
            print_info "Please fix the storage path configuration before deploying."
            exit 1
        fi
    else
        print_warning "Storage path validation script not found, skipping..."
    fi

}

# Create environment file
setup_environment() {
    print_info "Setting up environment..."
    
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        print_error "No .env configuration file found!"
        echo ""
        print_info "It looks like you haven't run the initial setup yet."
        print_info "Please run the setup first to configure your preferences:"
        echo ""
        print_info "  ./surge setup              # Interactive setup"
        print_info "  ./surge setup --auto       # Quick setup with defaults"
        print_info "  ./surge setup --custom     # Full customization"
        echo ""
        print_info "After setup, you can deploy with:"
        print_info "  ./surge deploy $1"
        echo ""
        exit 1
    fi
    
    # Check if this looks like a properly configured setup vs just a copied template
    INSTALL_TYPE=$(grep "^INSTALL_TYPE=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "")
    
    if [ -z "$INSTALL_TYPE" ] || [ "$INSTALL_TYPE" = "unknown" ]; then
        print_warning "⚠️  Configuration appears incomplete"
        echo ""
        print_info "Your .env file exists but may not be properly configured."
        echo ""
        read -p "Would you like to run setup now to ensure proper configuration? [Y/n]: " run_setup
        
        if [[ ! "$run_setup" =~ ^[Nn]$ ]]; then
            print_info "Running setup first..."
            exec "$SCRIPT_DIR/first-time-setup.sh" "--reconfigure"
        else
            print_info "Continuing with existing configuration..."
        fi
    fi
    
    print_info "✅ Environment configuration ready"
}

# Create directory structure
create_directories() {
    print_info "Creating directory structure for enabled services..."
    STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
    PUID=$(grep "^PUID=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "1000")
    PGID=$(grep "^PGID=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "1000")
    MEDIA_SERVER=$(grep "^MEDIA_SERVER=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "plex")

    # List of services and their required subfolders
    declare -A service_folders
    service_folders=(
        [Bazarr]="config media"
        [Bazarr]="config"
        [Radarr]="config"
        [Sonarr]="config"
        [NZBGet]="config downloads"
        [Plex]="config"
        [Emby]="config"
        [Jellyfin]="config"
        [Decypharr]="config"
        [Kometa]="config"
        [Posterizarr]="config"
        [Overseerr]="config"
        [Tautulli]="config"
        [CineSync]="config"
        [Placeholdarr]="config"
        [GAPS]="config"
        [Plex]="config media"
        [Emby]="config media"
        [Jellyfin]="config media"
    )

    # Only create folders for enabled services, and only copy default configs/envs if missing
    for service in "Bazarr" "Radarr" "Sonarr" "Prowlarr" "NZBGet" "RDT-Client" "Zurg" "cli_debrid" "Decypharr" "Kometa" "Posterizarr" "Overseerr" "Tautulli" "CineSync" "Placeholdarr" "GAPS"; do
        var_name="ENABLE_${service^^}"
        var_name="${var_name//-/_}"
        enabled=$(grep "^$var_name=" "$PROJECT_DIR/.env" | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
        if [ "$enabled" = "true" ]; then
            for sub in ${service_folders[$service]}; do
                mkdir -p "$STORAGE_PATH/$service/$sub"
            done
            # Only copy default config/env if missing
            default_config="$SCRIPT_DIR/initial-configs/${service,,}-config.yml"
            target_config="$STORAGE_PATH/$service/config/config.yml"
            if [ -f "$default_config" ] && [ ! -f "$target_config" ]; then
                cp "$default_config" "$target_config"
                print_info "Default config for $service copied to $target_config"
            fi
            # Example for env files (customize per service as needed)
            default_env="$SCRIPT_DIR/initial-configs/${service,,}.env"
            target_env="$STORAGE_PATH/$service/.env"
            if [ -f "$default_env" ] && [ ! -f "$target_env" ]; then
                cp "$default_env" "$target_env"
                print_info "Default env for $service copied to $target_env"
            fi
        fi
    done

    # Always create media server folders for the selected server
    case "$MEDIA_SERVER" in
        plex|Plex)
            mkdir -p "$STORAGE_PATH/Plex/config"
            ;;
        emby|Emby)
            mkdir -p "$STORAGE_PATH/Emby/config"
            ;;
        jellyfin|Jellyfin)
            mkdir -p "$STORAGE_PATH/Jellyfin/config"
            ;;
    esac

    # Set permissions
    if [ "$(id -u)" -eq 0 ]; then
        chown -R $PUID:$PGID "$STORAGE_PATH"
        chmod -R 755 "$STORAGE_PATH"
        print_success "Directory ownership and permissions set to $PUID:$PGID"
    else
        if sudo -n true 2>/dev/null; then
            sudo chown -R $PUID:$PGID "$STORAGE_PATH"
            sudo chmod -R 755 "$STORAGE_PATH"
            print_success "Directory ownership and permissions set to $PUID:$PGID (with sudo)"
        else
            print_warning "Setting directory ownership requires sudo privileges..."
            if sudo chown -R $PUID:$PGID "$STORAGE_PATH" && sudo chmod -R 755 "$STORAGE_PATH"; then
                print_success "Directory ownership and permissions set to $PUID:$PGID (with sudo)"
            else
                print_warning "Failed to set directory ownership/permissions. You may need to run manually:"
                print_warning "  sudo chown -R $PUID:$PGID $STORAGE_PATH"
                print_warning "  sudo chmod -R 755 $STORAGE_PATH"
            fi
        fi
    fi

    print_success "Directory structure created at $STORAGE_PATH for enabled services."

    # Dynamically generate Pangolin config after directories are created
    if python3 "$SCRIPT_DIR/configure-pangolin.py" "$STORAGE_PATH"; then
        print_success "Pangolin config.json generated in $STORAGE_PATH/Pangolin/config/"
    else
        print_warning "Failed to generate Pangolin config.json. Please check configure-pangolin.py."
    fi
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
    
    # Read environment variables for service enablement
    RD_API_TOKEN=$(grep "^RD_API_TOKEN=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "")
    ENABLE_CLI_DEBRID=$(grep "^ENABLE_CLI_DEBRID=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
    ENABLE_DECYPHARR=$(grep "^ENABLE_DECYPHARR=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
    ENABLE_PD_ZURG=$(grep "^ENABLE_PD_ZURG=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
    export RD_API_TOKEN ENABLE_CLI_DEBRID ENABLE_DECYPHARR ENABLE_PD_ZURG

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
    
    # Fix permissions on STORAGE_PATH before config generation and deployment
    if [ -n "$STORAGE_PATH" ]; then
        print_info "Ensuring correct permissions on $STORAGE_PATH (sudo chown -R 1000:1000)"
        if sudo chown -R 1000:1000 "$STORAGE_PATH"; then
            print_success "Permissions fixed on $STORAGE_PATH"
        else
            print_warning "Failed to set permissions on $STORAGE_PATH. You may need to fix manually."
        fi
    fi


    # Dynamically build PROFILES list from ENABLE_* variables in .env
    PROFILES="$media_server pangolin"
    [ "$(grep '^ENABLE_RADARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" radarr"
    [ "$(grep '^ENABLE_SONARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" sonarr"
    [ "$(grep '^ENABLE_BAZARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" bazarr"
    [ "$(grep '^ENABLE_PROWLARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" prowlarr"
    [ "$(grep '^ENABLE_NZBGET=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" nzbget"
    [ "$(grep '^ENABLE_RDT_CLIENT=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" rdt-client"
    [ "$(grep '^ENABLE_ZURG=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" zurg"
    [ "$(grep '^ENABLE_CLI_DEBRID=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" cli-debrid"
    [ "$(grep '^ENABLE_DECYPHARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" decypharr"
    [ "$(grep '^ENABLE_KOMETA=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" kometa"
    [ "$(grep '^ENABLE_POSTERIZARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" posterizarr"
    [ "$(grep '^ENABLE_OVERSEERR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" overseerr"
    [ "$(grep '^ENABLE_TAUTULLI=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" tautulli"
    [ "$(grep '^ENABLE_CINESYNC=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" cinesync"
    [ "$(grep '^ENABLE_PLACEHOLDARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" placeholdarr"
    [ "$(grep '^ENABLE_GAPS=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" gaps"
    [ "$(grep '^ENABLE_HOMEPAGE=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" homepage"
    [ "$(grep '^ENABLE_WATCHTOWER=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" watchtower"
    [ "$(grep '^ENABLE_PD_ZURG=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" pd_zurg"
    [ "$(grep '^ENABLE_SCANLY=' "$PROJECT_DIR/.env" | cut -d'=' -f2)" = "true" ] && PROFILES+=" scanly"

    # Build multiple --profile flags
    COMPOSE_PROFILE_FLAGS=""
    for profile in $PROFILES; do
        COMPOSE_PROFILE_FLAGS+=" --profile $profile"
    done
    # Generate CineSync configuration before deploying containers
    if echo "$PROFILES" | grep -q "cinesync"; then
        print_info "Generating CineSync configuration before container deployment..."
        STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
        export STORAGE_PATH
        if python3 "$SCRIPT_DIR/configure-cinesync.py"; then
            print_success "CineSync environment file created successfully!"
            # Wait for .env file to exist before continuing
            ENV_PATH="$STORAGE_PATH/CineSync/config/.env"
            WAIT_SECONDS=0
            while [ ! -f "$ENV_PATH" ] && [ $WAIT_SECONDS -lt 60 ]; do
                print_info "Waiting for CineSync .env file to be created... ($WAIT_SECONDS seconds)"
                sleep 2
                WAIT_SECONDS=$((WAIT_SECONDS+2))
            done
            if [ -f "$ENV_PATH" ]; then
                print_success "CineSync .env file detected: $ENV_PATH"
            else
                print_warning "CineSync .env file not found after waiting. Please check logs."
            fi
        else
            print_warning "Failed to generate CineSync environment file. You can run it manually:"
            print_warning "  python3 $SCRIPT_DIR/configure-cinesync.py"
        fi
    fi

    print_info "Starting deployment (phase 1: all services except Decypharr) with profiles:$COMPOSE_PROFILE_FLAGS"
    # Remove Decypharr from profiles for phase 1
    PHASE1_PROFILE_FLAGS=$(echo "$COMPOSE_PROFILE_FLAGS" | sed 's/--profile decypharr//g')
    eval docker compose $COMPOSE_FILES $PHASE1_PROFILE_FLAGS up -d
    print_success "Phase 1: All services except Decypharr deployed successfully!"

    # Configure services automatically
    configure_services

    # Run post-deployment configuration synchronously so API keys are ready before Decypharr config
    print_info "Running post-deployment configuration..."
    if [ -f "$SCRIPT_DIR/post-deploy-config.sh" ]; then
        # Export STORAGE_PATH for post-deploy script
        STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
        export STORAGE_PATH
        bash "$SCRIPT_DIR/post-deploy-config.sh" | tee "$PROJECT_DIR/logs/post-deploy.log"
        print_info "Post-deployment configuration complete. See logs/post-deploy.log for details."
    fi

    # Run Decypharr configuration as the very last step
    ENABLE_DECYPHARR_FLAG=$(grep '^ENABLE_DECYPHARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
    if [ "$ENABLE_DECYPHARR_FLAG" = "true" ] || echo "$COMPOSE_PROFILES" | grep -q "decypharr"; then
        print_info "Fixing permissions for Decypharr directories..."
        if sudo chown -R 1000:1000 "$STORAGE_PATH"; then
            print_success "Permissions fixed for $STORAGE_PATH"
        else
            print_warning "Failed to fix permissions for $STORAGE_PATH. You may need to fix manually."
        fi
        print_info "Generating Decypharr configuration..."
        if [ -f "$SCRIPT_DIR/configure-decypharr.py" ]; then
            if python3 "$SCRIPT_DIR/configure-decypharr.py" "$STORAGE_PATH"; then
                print_success "Decypharr configuration generated successfully!"
            else
                print_warning "Failed to generate Decypharr configuration. You can run it manually:"
                print_warning "  python3 $SCRIPT_DIR/configure-decypharr.py $STORAGE_PATH"
            fi
        else
            print_warning "configure-decypharr.py script not found in $SCRIPT_DIR. Skipping Decypharr configuration."
        fi
        print_info "Starting Decypharr container (phase 2)"
        eval docker compose $COMPOSE_FILES --profile decypharr up -d
        print_success "Phase 2: Decypharr container started!"
    fi
    
    print_info "Access your services:"
    echo "  - Homepage Dashboard: http://localhost:3000"
    echo "  - CineSync Media Manager: http://localhost:8082"
    if [ "$media_server" = "plex" ]; then
        echo "  - Plex Media Server: http://localhost:32400/web"
        print_info "Please open http://localhost:32400/web in your browser."
        print_info "Name your Plex server and click Next in the browser."
        read -p "After you have named your Plex server and clicked Next, press Enter to continue..."
        # Extract Plex token from Preferences.xml (correct location)
        PLEX_PREFS="$STORAGE_PATH/Plex/config/Library/Application Support/Plex Media Server/Preferences.xml"
        if [ -f "$PLEX_PREFS" ]; then
            PLEX_TOKEN=$(grep -o 'PlexOnlineToken="[^"]*"' "$PLEX_PREFS" | head -1 | sed 's/PlexOnlineToken="\([^"]*\)"/\1/')
            if [ -n "$PLEX_TOKEN" ]; then
                print_success "Extracted Plex token: $PLEX_TOKEN"
                # Save to .env
                if grep -q '^PLEX_TOKEN=' "$PROJECT_DIR/.env"; then
                    sed -i "s/^PLEX_TOKEN=.*/PLEX_TOKEN=$PLEX_TOKEN/" "$PROJECT_DIR/.env"
                else
                    echo "PLEX_TOKEN=$PLEX_TOKEN" >> "$PROJECT_DIR/.env"
                fi
                print_info "Plex token saved to .env file."
            else
                print_warning "Could not extract Plex token from Preferences.xml."
            fi
        else
            print_warning "Preferences.xml not found at $PLEX_PREFS. Plex may not be fully initialized yet."
        fi
    elif [ "$media_server" = "emby" ]; then
        echo "  - Emby Server: http://localhost:8096"
    elif [ "$media_server" = "jellyfin" ]; then
        echo "  - Jellyfin Server: http://localhost:8096"
    fi

    # Show optional service status messages
    if [ -n "$RD_API_TOKEN" ]; then
        echo "  - RDT-Client (Real-Debrid): http://localhost:6500"
    else
        echo ""
        print_warning "💡 RDT-Client not deployed - no Real-Debrid token found"
        print_info "   To enable RDT-Client:"
        print_info "   1. Add RD_API_TOKEN=your_token to .env file"
        print_info "   2. Run: ./surge deploy $media_server"
    fi

    # Show cli_debrid status
    if [ "$ENABLE_CLI_DEBRID" = "true" ]; then
        CLI_DEBRID_PORT=$(grep "^CLI_DEBRID_PORT=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "5000")
        echo "  - cli_debrid Web UI: http://localhost:${CLI_DEBRID_PORT}"
        echo "  - cli_debrid CLI: Available via ./surge exec cli-debrid"
    fi

    # Show Decypharr status
    if [ "$ENABLE_DECYPHARR" = "true" ]; then
        echo "  - Decypharr: http://localhost:8282"
    fi

    # Show pd_zurg status
    if [ "$ENABLE_PD_ZURG" = "true" ]; then
        echo "  - pd_zurg: http://localhost:9999"
    fi

    # Final permission fix to unlock all folders for Surge
    if [ -n "$STORAGE_PATH" ]; then
        print_info "Running final permission fix on $STORAGE_PATH (sudo chown -R 1000:1000)"
        if sudo chown -R 1000:1000 "$STORAGE_PATH"; then
            print_success "Final permissions fixed on $STORAGE_PATH"
        else
            print_warning "Failed to set final permissions on $STORAGE_PATH. You may need to fix manually."
        fi
    fi
}

# Configure services automatically
configure_services() {
    print_info "Configuring service connections automatically..."
    # ...existing code for other service configuration...

    # Generate Decypharr configuration last if Decypharr is enabled (by env or profile)
    ENABLE_DECYPHARR_FLAG=$(grep '^ENABLE_DECYPHARR=' "$PROJECT_DIR/.env" | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
    if [ "$ENABLE_DECYPHARR_FLAG" = "true" ] || echo "$COMPOSE_PROFILES" | grep -q "decypharr"; then
        print_info "Fixing permissions for Decypharr directories..."
        if sudo chown -R 1000:1000 "$STORAGE_PATH"; then
            print_success "Permissions fixed for $STORAGE_PATH"
        else
            print_warning "Failed to fix permissions for $STORAGE_PATH. You may need to fix manually."
        fi
        print_info "Generating Decypharr configuration..."
        if [ -f "$SCRIPT_DIR/configure-decypharr.py" ]; then
            if python3 "$SCRIPT_DIR/configure-decypharr.py" "$STORAGE_PATH"; then
                print_success "Decypharr configuration generated successfully!"
            else
                print_warning "Failed to generate Decypharr configuration. You can run it manually:"
                print_warning "  python3 $SCRIPT_DIR/configure-decypharr.py $STORAGE_PATH"
            fi
        else
            print_warning "configure-decypharr.py script not found in $SCRIPT_DIR. Skipping Decypharr configuration."
        fi
    fi
    
    # Read STORAGE_PATH from .env file or use default
    STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
    export STORAGE_PATH
    
    # Generate CineSync configuration if CineSync is enabled
    if echo "$COMPOSE_PROFILES" | grep -q "cinesync"; then
        print_info "Generating CineSync configuration..."
        # Always export STORAGE_PATH from .env before running the config script
        STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
        export STORAGE_PATH
        if python3 "$SCRIPT_DIR/configure-cinesync.py"; then
            print_success "CineSync configuration generated successfully!"
        else
            print_warning "Failed to generate CineSync configuration. You can run it manually:"
            print_warning "  python3 $SCRIPT_DIR/configure-cinesync.py"
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
        # Only generate API keys for services that do not already have them
        for service in "Prowlarr" "Radarr" "Sonarr"; do
            config_file="$STORAGE_PATH/$service/config/config.xml"
            if [ ! -f "$config_file" ]; then
                print_info "Generating initial API key for $service..."
                if python3 "$SCRIPT_DIR/inject-api-keys.py" --generate "$service" --config-dir "$STORAGE_PATH" 2>/dev/null; then
                    print_success "Initial API key for $service generated successfully!"
                else
                    print_info "API key for $service will be generated automatically when service starts"
                fi
            else
                print_info "API key for $service already exists, skipping generation"
            fi
        done
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
            validate_storage_path
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
    validate_storage_path
    setup_environment
    create_directories
    deploy_services "$MEDIA_SERVER" "$DEPLOYMENT_TYPE"

    # After deployment, generate libraries.json and create Plex libraries
    print_info "Generating libraries.json for Plex..."
    if python3 "$SCRIPT_DIR/generate_libraries_json.py"; then
        print_success "libraries.json generated successfully."
    else
        print_warning "Failed to generate libraries.json."
    fi

    print_info "Creating Plex libraries from libraries.json..."
    if python3 "$SCRIPT_DIR/plex_create_libraries.py"; then
        print_success "Plex libraries created successfully."
    else
        print_warning "Failed to create Plex libraries."
    fi
}

# Run main function
main "$@"
