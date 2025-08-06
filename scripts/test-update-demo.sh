#!/bin/bash

# ===========================================
# SURGE UPDATE DEMO SCRIPT
# ===========================================
# Simulates the update process with masked data

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

print_banner() {
    clear
    printf "\n"
    printf "\033[0;36m  ███████╗██╗   ██╗██████╗  ██████╗ \033[38;5;32m███████╗\033[0m\n"
    printf "\033[0;36m  ██╔════╝██║   ██║██╔══██╗\033[38;5;32m██╔════╝\033[0;36m ██╔════╝\033[0m\n"
    printf "\033[0;36m  ███████╗██║   ██║\033[38;5;32m██████╔╝██║  ███╗\033[0;36m█████╗\033[0m\n"
    printf "\033[38;5;32m  ╚════██║██║   ██║██╔══██╗██║   ██║\033[0;36m██╔══╝\033[0m\n"
    printf "\033[38;5;32m  ███████║╚██████╔╝██║  ██║╚██████╔╝\033[0;36m███████╗\033[0m\n"
    printf "\033[38;5;32m  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ \033[0;36m╚══════╝\033[0m\n"
    printf "\n"
    printf "  🌊 Update Manager\n"
    printf "\n"
}

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

simulate_update_check() {
    print_step "Checking for available updates..."
    echo ""
    
    print_info "Scanning container images for updates..."
    sleep 2
    
    echo "  ├─ linuxserver/radarr:latest"
    echo "  │  Current: sha256:abc123..."
    echo "  │  Remote:  sha256:def456..."
    echo "  │  Status:  🔄 Update available"
    echo "  │"
    echo "  ├─ linuxserver/sonarr:latest"
    echo "  │  Current: sha256:ghi789..."
    echo "  │  Remote:  sha256:jkl012..."
    echo "  │  Status:  🔄 Update available"
    echo "  │"
    echo "  ├─ linuxserver/prowlarr:latest"
    echo "  │  Current: sha256:mno345..."
    echo "  │  Remote:  sha256:pqr678..."
    echo "  │  Status:  🔄 Update available"
    echo "  │"
    echo "  ├─ linuxserver/bazarr:latest"
    echo "  │  Current: sha256:stu901..."
    echo "  │  Remote:  sha256:vwx234..."
    echo "  │  Status:  🔄 Update available"
    echo "  │"
    echo "  ├─ linuxserver/overseerr:latest"
    echo "  │  Current: sha256:yza567..."
    echo "  │  Remote:  sha256:yza567..."
    echo "  │  Status:  ✓ Up to date"
    echo "  │"
    echo "  └─ plexinc/pms-docker:latest"
    echo "     Current: sha256:bcd890..."
    echo "     Remote:  sha256:efg123..."
    echo "     Status:  🔄 Update available"
    echo ""
    
    sleep 2
    print_warning "5 container images have updates available!"
    print_info "Estimated download size: ~2.1 GB"
    echo ""
}

simulate_backup_process() {
    print_step "Preserving user configurations..."
    echo ""
    
    local timestamp="2025-08-06_$(date +%H%M%S)"
    
    print_info "Creating temporary backup..."
    echo "  ├─ Backup location: /tmp/surge_config_backup_$timestamp"
    echo "  ├─ Backing up .env file"
    echo "  ├─ Backing up custom configurations"
    sleep 1
    
    local configs=(
        "config/radarr/config.xml"
        "config/sonarr/config.xml"
        "config/prowlarr/config.xml"
        "config/bazarr/config.ini"
        "config/overseerr/settings.json"
        "config/homepage/services.yaml"
    )
    
    for config in "${configs[@]}"; do
        echo "  ├─ Backing up $config"
        sleep 0.2
    done
    
    echo "  └─ Configuration backup complete"
    echo ""
    print_success "User configurations preserved safely"
}

simulate_image_pulling() {
    print_step "Pulling latest container images..."
    echo ""
    
    local images=(
        "linuxserver/radarr:latest"
        "linuxserver/sonarr:latest" 
        "linuxserver/prowlarr:latest"
        "linuxserver/bazarr:latest"
        "plexinc/pms-docker:latest"
        "linuxserver/homepage:latest"
        "cinesync/cinesync:latest"
    )
    
    for image in "${images[@]}"; do
        print_info "Pulling $image..."
        
        # Simulate realistic download progress
        local layers=("sha256:abc123" "sha256:def456" "sha256:ghi789" "sha256:jkl012")
        for layer in "${layers[@]}"; do
            echo "  ${layer:0:12}: Download complete"
            sleep 0.3
        done
        echo "  ✓ Image pull complete"
        echo ""
        sleep 0.5
    done
    
    print_success "Successfully pulled all latest images"
}

simulate_container_recreation() {
    print_step "Recreating containers with latest images..."
    echo ""
    
    print_info "Stopping services gracefully..."
    local services=("homepage" "overseerr" "bazarr" "sonarr" "radarr" "prowlarr" "plex")
    
    for service in "${services[@]}"; do
        echo "  ├─ Stopping surge-$service..."
        sleep 0.3
    done
    echo "  └─ All services stopped"
    echo ""
    
    print_info "Creating containers with updated images..."
    for service in "${services[@]}"; do
        echo "  ├─ Creating surge-$service..."
        sleep 0.4
    done
    echo "  └─ All containers created"
    echo ""
    
    print_info "Starting services..."
    for service in "${services[@]}"; do
        echo "  ├─ Starting surge-$service... ✓"
        sleep 0.3
    done
    echo "  └─ All services started"
    echo ""
    
    print_success "Successfully recreated containers"
}

simulate_config_restoration() {
    print_step "Restoring user configurations..."
    echo ""
    
    print_info "Restoring preserved configurations..."
    echo "  ├─ Restoring .env file"
    echo "  ├─ Restoring Radarr configuration"
    echo "  ├─ Restoring Sonarr configuration"
    echo "  ├─ Restoring Prowlarr configuration"
    echo "  ├─ Restoring Bazarr configuration"
    echo "  ├─ Restoring Overseerr settings"
    echo "  └─ Restoring Homepage configuration"
    sleep 2
    
    print_success "User configurations restored successfully"
}

simulate_health_check() {
    print_step "Waiting for containers to be healthy..."
    echo ""
    
    simulate_wait "Checking service health" 3
    
    echo ""
    print_info "Service health status:"
    local services=(
        "surge-prowlarr:9696"
        "surge-radarr:7878"
        "surge-sonarr:8989"
        "surge-bazarr:6767"
        "surge-overseerr:5055"
        "surge-plex:32400"
        "surge-homepage:3000"
    )
    
    for service in "${services[@]}"; do
        echo "  ├─ $service: ✓ Healthy"
        sleep 0.4
    done
    echo "  └─ All services operational"
    echo ""
    
    print_success "All containers are healthy"
}

simulate_cleanup() {
    print_step "Cleaning up old Docker images..."
    echo ""
    
    print_info "Removing unused images..."
    echo "  ├─ Deleted: sha256:old123456... (radarr:previous)"
    echo "  ├─ Deleted: sha256:old789012... (sonarr:previous)" 
    echo "  ├─ Deleted: sha256:old345678... (prowlarr:previous)"
    echo "  ├─ Deleted: sha256:old901234... (bazarr:previous)"
    echo "  └─ Deleted: sha256:old567890... (plex:previous)"
    echo ""
    echo "Total reclaimed space: 1.8 GB"
    sleep 2
    
    print_success "Cleaned up old images"
}

simulate_notification() {
    print_info "📱 Sending Discord notification..."
    echo ""
    echo "  🔔 Notification sent to Discord:"
    echo "  ┌─────────────────────────────────────────┐"
    echo "  │ 🚀 Surge Update Complete                │"
    echo "  │                                         │"
    echo "  │ ✅ Updated: 5 containers                │"
    echo "  │ 📊 Status: All services healthy         │"
    echo "  │ ⏱️  Duration: 3m 42s                    │"
    echo "  │ 💾 Space freed: 1.8 GB                  │"
    echo "  │                                         │"
    echo "  │ All services are running normally!      │"
    echo "  └─────────────────────────────────────────┘"
    echo ""
    sleep 2
}

simulate_version_info() {
    print_info "📋 Update Summary:"
    echo ""
    echo "  ┌─ Updated Services"
    echo "  ├─ Radarr:    v4.7.5.7809 → v4.8.0.7850"
    echo "  ├─ Sonarr:    v3.0.10.1567 → v3.0.11.1675"
    echo "  ├─ Prowlarr:  v1.10.5.4116 → v1.11.0.4204"
    echo "  ├─ Bazarr:    v1.4.0 → v1.4.1"
    echo "  └─ Plex:      v1.32.7.7621 → v1.32.8.7639"
    echo ""
    echo "  ┌─ Unchanged Services"
    echo "  ├─ Overseerr: v1.33.2 (up to date)"
    echo "  ├─ Homepage:  v0.8.10 (up to date)"
    echo "  └─ CineSync:  v2.1.0 (up to date)"
    echo ""
}

simulate_complete_update() {
    print_banner
    
    echo -e "${YELLOW}Surge Container Update${NC}"
    echo ""
    print_info "Starting Surge update process..."
    echo ""
    sleep 2
    
    simulate_update_check
    sleep 1
    
    simulate_backup_process
    sleep 1
    
    simulate_image_pulling
    sleep 1
    
    simulate_container_recreation
    sleep 1
    
    simulate_config_restoration
    sleep 1
    
    simulate_health_check
    sleep 1
    
    simulate_cleanup
    sleep 1
    
    simulate_notification
    sleep 1
    
    simulate_version_info
    
    print_success "🎉 Surge update completed successfully!"
    echo ""
    
    print_info "📊 Update Statistics:"
    echo "  ├─ Containers updated: 5"
    echo "  ├─ Total download size: 2.1 GB"
    echo "  ├─ Space reclaimed: 1.8 GB"
    echo "  ├─ Update duration: 3m 42s"
    echo "  └─ Services restarted: 7"
    echo ""
    
    print_info "🌐 All services are accessible:"
    echo "  ├─ Homepage: http://localhost:3000"
    echo "  ├─ Radarr: http://localhost:7878"
    echo "  ├─ Sonarr: http://localhost:8989"
    echo "  ├─ Prowlarr: http://localhost:9696"
    echo "  └─ Plex: http://localhost:32400/web"
    echo ""
    
    print_success "🚀 Your Surge stack is now running the latest versions!"
}

# Help message
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Surge Update Demo Script"
    echo ""
    echo "This script simulates the './surge --update' command for demonstration"
    echo "purposes. All version numbers and image hashes are sanitized."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "The demo will show:"
    echo "  - Update availability checking"
    echo "  - Configuration backup process"
    echo "  - Container image pulling"
    echo "  - Service recreation with new images"
    echo "  - Configuration restoration"
    echo "  - Health checking"
    echo "  - Cleanup and notifications"
    echo ""
    echo "Runtime: ~4-5 minutes"
    exit 0
fi

simulate_complete_update
