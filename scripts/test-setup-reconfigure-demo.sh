#!/bin/bash

# ===========================================
# SURGE SETUP --RECONFIGURE DEMO SCRIPT
# ===========================================
# Simulates the reconfiguration experience
# for existing Surge installations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
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
    echo -e "${PURPLE}[STEP]${NC} $1"
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
    printf "  🌊 Unified Media Management Stack\n"
    printf "\n"
}

simulate_user_input() {
    local prompt="$1"
    local response="$2"
    local delay="${3:-1}"
    
    printf "%s" "$prompt"
    sleep $delay
    echo -e "${CYAN}$response${NC}"
    sleep 0.5
}

simulate_reconfigure_welcome() {
    print_banner
    
    echo -e "${YELLOW}Surge Reconfiguration${NC}"
    echo ""
    print_info "Existing Surge installation detected"
    echo ""
    
    print_info "Checking current configuration..."
    sleep 1
    echo "  ├─ Found .env configuration file"
    echo "  ├─ Found .surge_initialized marker"
    echo "  ├─ Services: 17 containers configured"
    echo "  └─ Storage: /home/user/surge-media"
    echo ""
    
    print_warning "This will backup your current configuration and update settings"
    echo ""
    sleep 2
}

simulate_backup_current() {
    print_step "Backing up current configuration..."
    echo ""
    
    print_info "Creating configuration backup..."
    sleep 1
    
    local timestamp="2025-08-06_14-30-15"
    echo "  ├─ Backing up .env → .env.backup.$timestamp"
    echo "  ├─ Backing up docker-compose.yml → docker-compose.yml.backup.$timestamp"
    echo "  └─ Backing up service configs → config.backup.$timestamp/"
    echo ""
    
    print_success "Backup created: surge-backup-$timestamp.tar.gz"
    sleep 1
}

simulate_version_check() {
    print_step "Checking for configuration updates..."
    echo ""
    
    print_info "Analyzing configuration version..."
    sleep 1
    
    echo "  ├─ Current config version: v2.1.0"
    echo "  ├─ Latest config version:  v2.3.0"
    echo "  └─ Updates available: Yes"
    echo ""
    
    print_warning "New variables detected in v2.3.0:"
    echo "  ├─ ENABLE_GPU_ACCELERATION (for hardware transcoding)"
    echo "  ├─ KOMETA_SCHEDULE (metadata update scheduling)"
    echo "  ├─ DISCORD_NOTIFY_HEALTH (health check notifications)"
    echo "  └─ ZURG_MOUNT_OPTIONS (advanced Zurg configuration)"
    echo ""
    
    sleep 2
}

simulate_reconfiguration_options() {
    print_step "Reconfiguration Options"
    echo ""
    echo "Choose what you'd like to reconfigure:"
    echo ""
    echo "1) Update configuration only (add new variables)"
    echo "2) Change media server (Plex → Jellyfin/Emby)"
    echo "3) Modify service selection (add/remove services)"
    echo "4) Update storage paths and user settings"
    echo "5) Complete reconfiguration (all settings)"
    echo ""
    
    simulate_user_input "Enter choice (1-5): " "1"
    echo ""
    print_success "Selected: Update configuration only"
}

simulate_config_update() {
    print_step "Updating configuration..."
    echo ""
    
    print_info "Adding new configuration variables..."
    sleep 1
    
    echo "  ├─ ENABLE_GPU_ACCELERATION=false (can be enabled later)"
    echo "  ├─ KOMETA_SCHEDULE=weekly (runs every Sunday at 2 AM)"
    echo "  ├─ DISCORD_NOTIFY_HEALTH=true (matches existing notification settings)"
    echo "  └─ ZURG_MOUNT_OPTIONS=-o uid=1000,gid=1000 (optimal defaults)"
    echo ""
    
    print_info "Reviewing existing settings..."
    sleep 1
    echo "  ├─ Media Server: Plex (keeping current)"
    echo "  ├─ Storage Path: /home/user/surge-media (keeping current)"
    echo "  ├─ User/Group: 1000:1000 (keeping current)"
    echo "  ├─ Services: 17 enabled (keeping current)"
    echo "  └─ Discord Webhook: ********** (keeping current)"
    echo ""
    
    print_info "Merging configurations..."
    sleep 1
    echo "  ├─ Preserving custom modifications"
    echo "  ├─ Adding new variables with defaults"
    echo "  ├─ Updating deprecated settings"
    echo "  └─ Validating final configuration"
    echo ""
    
    sleep 1
    print_success "Configuration updated successfully!"
}

simulate_service_updates() {
    print_step "Checking service configurations..."
    echo ""
    
    print_info "Analyzing service compatibility..."
    sleep 1
    
    echo "  ├─ Docker Compose profiles: ✓ Compatible"
    echo "  ├─ Service dependencies: ✓ Resolved"
    echo "  ├─ Port configurations: ✓ No conflicts"
    echo "  └─ Volume mappings: ✓ Valid paths"
    echo ""
    
    print_info "Service configuration status:"
    echo "  ├─ Core services (Radarr, Sonarr, Prowlarr): ✓ Up to date"
    echo "  ├─ Media server (Plex): ✓ Current configuration preserved"
    echo "  ├─ Download clients: ✓ Existing configs maintained"
    echo "  ├─ Processing pipeline: ✓ Updated with new scheduling"
    echo "  └─ Monitoring (Watchtower): ✓ Enhanced health checks enabled"
    echo ""
    
    sleep 2
}

simulate_optional_features() {
    print_step "New Feature Configuration"
    echo ""
    
    print_info "Would you like to configure new features?"
    echo ""
    
    # GPU Acceleration
    echo "🚀 GPU Hardware Acceleration"
    echo "Enable GPU acceleration for Plex transcoding?"
    echo "Requires: NVIDIA GPU with Docker runtime configured"
    
    simulate_user_input "Enable GPU acceleration? [y/N]: " "n"
    echo "Keeping GPU acceleration disabled"
    echo ""
    
    # Health Notifications
    echo "🔔 Enhanced Health Notifications"
    echo "Receive Discord notifications for service health issues?"
    echo "Will alert on container restarts, failed health checks, etc."
    
    simulate_user_input "Enable health notifications? [Y/n]: " ""
    echo "Health notifications enabled (default)"
    echo ""
    
    # Metadata Scheduling
    echo "📅 Metadata Update Scheduling"
    echo "Current: Weekly metadata updates (Sundays at 2 AM)"
    echo "Options: daily, weekly, monthly, or custom cron"
    
    simulate_user_input "Keep weekly schedule? [Y/n]: " ""
    echo "Keeping weekly metadata update schedule"
    echo ""
}

simulate_validation() {
    print_step "Validating reconfiguration..."
    echo ""
    
    print_info "Running configuration validation..."
    sleep 1
    
    echo "  ├─ Environment variables: ✓ All required variables present"
    echo "  ├─ File permissions: ✓ Correct ownership and permissions"
    echo "  ├─ Docker configuration: ✓ Valid compose file structure"
    echo "  ├─ Network configuration: ✓ No port conflicts detected"
    echo "  └─ Storage validation: ✓ All paths accessible and writable"
    echo ""
    
    print_info "Checking service readiness..."
    sleep 1
    echo "  ├─ Database migrations: ✓ No migrations required"
    echo "  ├─ API key compatibility: ✓ Existing keys remain valid"
    echo "  ├─ Configuration templates: ✓ Updated with new variables"
    echo "  └─ Backup integrity: ✓ Rollback available if needed"
    echo ""
    
    print_success "Validation complete - configuration is ready!"
}

simulate_completion() {
    print_step "Reconfiguration Complete!"
    echo ""
    
    print_success "🎉 Surge has been successfully reconfigured!"
    echo ""
    
    print_info "What changed:"
    echo "  ├─ Added 4 new configuration variables"
    echo "  ├─ Updated service scheduling options"
    echo "  ├─ Enhanced Discord notification features"
    echo "  └─ Improved health monitoring capabilities"
    echo ""
    
    print_info "Next steps:"
    echo "  1. Restart services to apply changes: ./surge restart"
    echo "  2. Verify services are running:       ./surge status"
    echo "  3. Check updated dashboard:           http://localhost:3000"
    echo ""
    
    print_info "📚 New Features Available:"
    echo "  ├─ Enhanced health notifications via Discord"
    echo "  ├─ Improved metadata update scheduling"
    echo "  ├─ Better service monitoring and alerting"
    echo "  └─ GPU acceleration support (when enabled)"
    echo ""
    
    print_warning "Optional actions:"
    echo "  ├─ Review new settings in .env file"
    echo "  ├─ Test Discord health notifications"
    echo "  └─ Configure GPU acceleration if desired"
    echo ""
    
    print_success "🚀 Your Surge stack is updated and ready!"
}

main() {
    simulate_reconfigure_welcome
    sleep 1
    
    simulate_backup_current
    sleep 1
    
    simulate_version_check
    sleep 1
    
    simulate_reconfiguration_options
    sleep 1
    
    simulate_config_update
    sleep 1
    
    simulate_service_updates
    sleep 1
    
    simulate_optional_features
    sleep 1
    
    simulate_validation
    sleep 1
    
    simulate_completion
}

# Help message
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Surge Setup --Reconfigure Demo Script"
    echo ""
    echo "This script simulates the './surge setup --reconfigure' command for"
    echo "demonstration purposes. All configuration values are sanitized."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "The demo will show:"
    echo "  - Detection of existing installation"
    echo "  - Configuration backup process"
    echo "  - Version checking and update detection"
    echo "  - Reconfiguration options selection"
    echo "  - Configuration merging and updates"
    echo "  - New feature configuration"
    echo "  - Validation and completion"
    echo ""
    echo "Runtime: ~2-3 minutes"
    exit 0
fi

main "$@"
