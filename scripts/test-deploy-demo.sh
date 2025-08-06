#!/bin/bash

# ===========================================
# SURGE DEPLOYMENT DEMO SCRIPT
# ===========================================
# This script simulates a successful deployment
# with masked API keys and sanitized paths for
# demonstration and recording purposes.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Demo configuration
DEMO_STORAGE_PATH="/home/user/surge-media"
DEMO_MEDIA_SERVER="plex"

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

print_header() {
    echo -e "${PURPLE}=====================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}=====================================${NC}"
    echo ""
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

# Simulate waiting with progress
simulate_wait() {
    local message="$1"
    local duration="$2"
    local steps=10
    local step_duration=$((duration / steps))
    
    print_info "$message"
    for i in $(seq 1 $steps); do
        printf "."
        sleep $step_duration
    done
    echo ""
}

# Simulate Docker Compose operations
simulate_docker_compose() {
    local action="$1"
    local services=("prowlarr" "radarr" "sonarr" "bazarr" "overseerr" "cinesync" "homepage" "$DEMO_MEDIA_SERVER")
    
    case $action in
        "pull")
            print_info "Pulling Docker images..."
            for service in "${services[@]}"; do
                echo "Pulling $service... ✓"
                sleep 0.3
            done
            ;;
        "up")
            print_info "Starting services..."
            for service in "${services[@]}"; do
                echo "Starting surge-$service... ✓"
                sleep 0.5
            done
            ;;
    esac
}

# Simulate API key discovery
simulate_api_discovery() {
    print_header "    API Key Discovery & Configuration    "
    
    simulate_wait "Waiting for services to generate API keys..." 3
    
    print_success "Discovered API Keys:"
    echo "  ├─ Prowlarr:  ****************************************"
    echo "  ├─ Radarr:    ****************************************"
    echo "  ├─ Sonarr:    ****************************************"
    echo "  ├─ Bazarr:    ****************************************"
    echo "  └─ Overseerr: ****************************************"
    echo ""
    
    print_info "Configuring service connections..."
    
    # Simulate Prowlarr configuration
    print_info "Configuring Prowlarr applications..."
    simulate_wait "  └─ Adding Radarr application" 2
    print_success "  ✓ Radarr application configured successfully"
    
    simulate_wait "  └─ Adding Sonarr application" 2
    print_success "  ✓ Sonarr application configured successfully"
    
    # Simulate indexer configuration
    print_info "Configuring indexers..."
    local indexers=("1337x" "RARBG" "The Pirate Bay" "Nyaa" "TorrentGalaxy")
    for indexer in "${indexers[@]}"; do
        echo "  ├─ $indexer... ✓"
        sleep 0.3
    done
    print_success "  ✓ 5 indexers configured and tested"
    
    # Simulate Bazarr configuration
    print_info "Configuring Bazarr connections..."
    simulate_wait "  └─ Connecting to Radarr" 1
    print_success "  ✓ Radarr connection established"
    simulate_wait "  └─ Connecting to Sonarr" 1
    print_success "  ✓ Sonarr connection established"
    
    # Simulate Overseerr configuration
    print_info "Configuring Overseerr..."
    simulate_wait "  └─ Setting up TMDB integration" 2
    print_success "  ✓ TMDB API configured (Key: tmdb_********)"
    simulate_wait "  └─ Connecting to Radarr and Sonarr" 2
    print_success "  ✓ Media server connections established"
}

# Simulate environment setup
simulate_environment_setup() {
    print_header "    Environment Setup    "
    
    print_info "Checking prerequisites..."
    echo "  ├─ Docker: ✓ (version 24.0.7)"
    echo "  ├─ Docker Compose: ✓ (version 2.21.0)"
    echo "  └─ Available disk space: ✓ (250GB free)"
    
    print_info "Loading environment configuration..."
    echo "  ├─ Storage Path: $DEMO_STORAGE_PATH"
    echo "  ├─ Media Server: $DEMO_MEDIA_SERVER"
    echo "  ├─ User ID: 1000"
    echo "  ├─ Group ID: 1000"
    echo "  └─ Timezone: America/New_York"
    
    print_success "Environment validated successfully"
}

# Simulate directory creation
simulate_directory_creation() {
    print_header "    Directory Structure Creation    "
    
    print_info "Creating storage directories at $DEMO_STORAGE_PATH..."
    
    local directories=(
        "Radarr/config"
        "Sonarr/config" 
        "Prowlarr/config"
        "Bazarr/config"
        "Overseerr/config"
        "CineSync/config"
        "Homepage/config"
        "media/movies"
        "media/tv"
        "media/anime"
        "downloads/complete"
        "downloads/incomplete"
    )
    
    for dir in "${directories[@]}"; do
        echo "  ├─ Creating $dir/"
        sleep 0.1
    done
    
    print_info "Setting proper ownership for storage directories..."
    simulate_wait "  └─ Setting ownership to 1000:1000" 2
    print_success "Directory ownership set to 1000:1000"
    
    print_success "Directory structure created at $DEMO_STORAGE_PATH"
}

# Simulate service deployment
simulate_deployment() {
    print_header "    Service Deployment    "
    
    simulate_docker_compose "pull"
    echo ""
    simulate_docker_compose "up"
    echo ""
    
    print_success "All services started successfully!"
}

# Simulate service configuration
simulate_service_configuration() {
    print_header "    Service Configuration    "
    
    # Simulate CineSync configuration
    print_info "Generating CineSync configuration..."
    simulate_wait "  └─ Configuring TMDB integration" 2
    print_success "CineSync configuration generated successfully!"
    
    # Simulate service readiness check
    print_info "Waiting for services to be ready..."
    local services=("Prowlarr:9696" "Radarr:7878" "Sonarr:8989" "Bazarr:6767" "Overseerr:5055")
    for service in "${services[@]}"; do
        simulate_wait "  └─ Checking $service" 1
        print_success "  ✓ $service is ready!"
    done
}

# Simulate post-deployment configuration
simulate_post_deployment() {
    print_header "    Post-Deployment Configuration    "
    
    print_info "Starting post-deployment configuration..."
    echo ""
    
    simulate_api_discovery
    echo ""
    
    # Simulate additional configurations
    print_info "Configuring quality profiles..."
    echo "  ├─ Radarr: HD-1080p profile set as default"
    echo "  └─ Sonarr: HD-720p/1080p profile set as default"
    
    print_info "Configuring download clients..."
    echo "  ├─ qBittorrent: Connected and tested"
    echo "  └─ Download paths configured"
    
    print_success "Post-deployment configuration completed!"
}

# Simulate final status
show_final_status() {
    print_header "    Deployment Complete    "
    
    print_success "🎉 Surge deployment completed successfully!"
    echo ""
    
    print_info "Access your services:"
    echo "  ┌─ Core Services"
    echo "  ├─ Homepage Dashboard: http://localhost:3000"
    echo "  ├─ CineSync Media Manager: http://localhost:8082"
    echo "  └─ Plex Media Server: http://localhost:32400/web"
    echo ""
    echo "  ┌─ Management Services"
    echo "  ├─ Prowlarr (Indexers): http://localhost:9696"
    echo "  ├─ Radarr (Movies): http://localhost:7878"
    echo "  ├─ Sonarr (TV Shows): http://localhost:8989"
    echo "  ├─ Bazarr (Subtitles): http://localhost:6767"
    echo "  └─ Overseerr (Requests): http://localhost:5055"
    echo ""
    
    print_info "📚 Quick Start Guide:"
    echo "  1. Visit Homepage at http://localhost:3000 for service overview"
    echo "  2. Configure Plex libraries via CineSync at http://localhost:8082"
    echo "  3. Add indexers in Prowlarr at http://localhost:9696"
    echo "  4. Set up quality profiles in Radarr and Sonarr"
    echo "  5. Users can request media via Overseerr at http://localhost:5055"
    echo ""
    
    print_info "🔒 Security Notes:"
    echo "  ├─ All API keys have been automatically generated"
    echo "  ├─ Services are configured with secure inter-communication"
    echo "  └─ Default credentials should be changed in production"
    echo ""
    
    print_success "🚀 Your Surge media stack is ready to use!"
}

# Main execution
main() {
    clear
    print_banner
    
    echo "Starting Surge deployment with Plex Media Server..."
    echo ""
    sleep 2
    
    simulate_environment_setup
    echo ""
    sleep 1
    
    simulate_directory_creation  
    echo ""
    sleep 1
    
    simulate_deployment
    echo ""
    sleep 1
    
    simulate_service_configuration
    echo ""
    sleep 1
    
    simulate_post_deployment
    echo ""
    sleep 1
    
    show_final_status
}

# Show usage if help requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Surge Deployment Demo Script"
    echo ""
    echo "This script simulates a successful Surge deployment for demonstration"
    echo "purposes. All API keys, tokens, and sensitive paths are masked."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "The demo will show:"
    echo "  - Environment setup and validation"
    echo "  - Directory structure creation"
    echo "  - Service deployment with Docker Compose"
    echo "  - Automatic API key discovery and configuration"
    echo "  - Service interconnection setup"
    echo "  - Final deployment status and access URLs"
    echo ""
    exit 0
fi

# Run the demo
main "$@"
