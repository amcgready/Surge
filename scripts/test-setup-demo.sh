#!/bin/bash

# ===========================================
# SURGE SETUP DEMO SCRIPT
# ===========================================
# Simulates the initial setup wizard experience
# with masked sensitive information

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

simulate_typing() {
    local text="$1"
    local delay="${2:-0.05}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    echo
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

simulate_setup_welcome() {
    print_banner
    
    echo -e "${YELLOW}Welcome to Surge!${NC}"
    echo ""
    echo "🌊 Let's set up your unified media management stack!"
    echo ""
    print_info "Checking prerequisites..."
    sleep 1
    echo "  ├─ Docker: ✓ (version 24.0.7)"
    echo "  ├─ Docker Compose: ✓ (version 2.21.0)"
    echo "  └─ Available disk space: ✓ (250GB free)"
    echo ""
    sleep 2
}

simulate_installation_type() {
    print_step "Choose your installation type..."
    echo ""
    echo "🚀 Surge Installation Options:"
    echo ""
    echo "1) Auto Install (Recommended)"
    echo "   ✅ Quick setup with sensible defaults"
    echo "   ✅ Only asks for essential choices (media server, storage)"
    echo "   ✅ Full stack deployment with all features"
    echo "   ✅ Perfect for most users"
    echo ""
    echo "2) Custom Install (Advanced)"
    echo "   ✅ Complete control over every setting"
    echo "   ✅ Choose specific services to deploy"
    echo "   ✅ Configure all environment variables"
    echo "   ✅ Perfect for power users"
    echo ""
    
    simulate_user_input "Enter choice (1-2): " "1"
    echo ""
    print_success "Selected: Auto Install"
}

simulate_auto_setup() {
    print_step "🚀 Auto Installation Setup"
    echo ""
    print_info "This will deploy the full Surge stack with optimal defaults."
    echo "We'll only ask for the essentials!"
    echo ""
    
    # Media server choice
    echo "Choose your media server:"
    echo "1) Plex Media Server (Premium)"
    echo "2) Jellyfin (Free & Open Source)"
    echo "3) Emby (Feature-rich)"
    echo ""
    
    simulate_user_input "Enter choice (1-3): " "1"
    echo ""
    
    # Storage configuration
    print_info "Storage Configuration"
    echo "Where should Surge store your media and configurations?"
    echo "Default: /opt/surge (recommended for most users)"
    
    simulate_user_input "Storage path [/opt/surge]: " ""
    echo "Using default: /home/user/surge-media"
    echo ""
    
    # Auto-detected settings
    print_info "Auto-detecting system configuration..."
    sleep 1
    echo "  ├─ User ID: 1000"
    echo "  ├─ Group ID: 1000"
    echo "  └─ Timezone: America/New_York"
    echo ""
    
    # Discord notifications
    print_info "🔔 Discord Notifications (Optional)"
    echo "Want to receive notifications about updates and processing?"
    
    simulate_user_input "Discord webhook URL (optional): " "https://discord.com/api/webhooks/********/**********************"
    echo ""
    
    print_success "Auto configuration complete! Deploying full stack with all features."
}

simulate_env_generation() {
    print_step "Generating configuration..."
    echo ""
    
    print_info "Creating .env configuration file..."
    sleep 1
    
    echo "  ├─ Media Server: Plex"
    echo "  ├─ Storage Path: /home/user/surge-media"
    echo "  ├─ User/Group: 1000:1000"
    echo "  ├─ Timezone: America/New_York"
    echo "  ├─ Discord Webhook: ********** (configured)"
    echo "  ├─ Services: Full stack (17 services)"
    echo "  └─ Auto-updates: Enabled"
    echo ""
    
    print_info "Generated configuration variables:"
    echo "  ┌─ Core Settings"
    echo "  ├─ STORAGE_PATH=/home/user/surge-media"
    echo "  ├─ PUID=1000"
    echo "  ├─ PGID=1000"
    echo "  └─ TZ=America/New_York"
    echo ""
    echo "  ┌─ Media Server"
    echo "  ├─ MEDIA_SERVER=plex"
    echo "  └─ PLEX_PORT=32400"
    echo ""
    echo "  ┌─ Service Ports"
    echo "  ├─ HOMEPAGE_PORT=3000"
    echo "  ├─ RADARR_PORT=7878"
    echo "  ├─ SONARR_PORT=8989"
    echo "  ├─ PROWLARR_PORT=9696"
    echo "  └─ BAZARR_PORT=6767"
    echo ""
    echo "  ┌─ Notifications"
    echo "  ├─ DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/********"
    echo "  ├─ DISCORD_NOTIFY_UPDATES=true"
    echo "  └─ NOTIFICATION_TITLE_PREFIX=Surge"
    echo ""
    
    sleep 2
    print_success "Configuration file (.env) created successfully!"
}

simulate_initialization() {
    print_step "Initializing Surge..."
    echo ""
    
    print_info "Setting up directory structure..."
    sleep 1
    
    local directories=(
        "config/radarr"
        "config/sonarr"
        "config/prowlarr"
        "config/bazarr"
        "config/overseerr"
        "config/plex"
        "data/media/movies"
        "data/media/tv"
        "data/downloads"
        "logs"
    )
    
    for dir in "${directories[@]}"; do
        echo "  ├─ Creating $dir/"
        sleep 0.1
    done
    
    echo ""
    print_info "Setting up Docker Compose profiles..."
    sleep 1
    echo "  ├─ Core services profile"
    echo "  ├─ Plex media server profile"
    echo "  ├─ Processing pipeline profile"
    echo "  └─ Monitoring profile"
    echo ""
    
    print_info "Initializing service configurations..."
    sleep 1
    echo "  ├─ Homepage dashboard config"
    echo "  ├─ CineSync media manager config"
    echo "  ├─ Kometa metadata config"
    echo "  └─ Watchtower update config"
    echo ""
    
    print_success "Initialization complete!"
}

simulate_completion() {
    print_step "Setup Complete!"
    echo ""
    
    print_success "🎉 Surge has been successfully configured!"
    echo ""
    
    print_info "Next steps:"
    echo "  1. Deploy your stack:  ./surge deploy plex"
    echo "  2. Access dashboard:   http://localhost:3000"
    echo "  3. Configure services: ./surge auto-config"
    echo ""
    
    print_info "📚 Quick Start Guide:"
    echo "  ├─ Homepage will be available at http://localhost:3000"
    echo "  ├─ Plex will be available at http://localhost:32400/web"
    echo "  ├─ CineSync will be available at http://localhost:8082"
    echo "  └─ All service configs are in /home/user/surge-media/config/"
    echo ""
    
    print_warning "Remember to:"
    echo "  ├─ Add your TMDB API key for metadata"
    echo "  ├─ Configure indexers in Prowlarr"
    echo "  └─ Set up quality profiles in Radarr/Sonarr"
    echo ""
    
    print_success "🚀 Run './surge deploy plex' to start your media stack!"
}

main() {
    simulate_setup_welcome
    sleep 1
    
    simulate_installation_type
    sleep 1
    
    simulate_auto_setup
    sleep 1
    
    simulate_env_generation
    sleep 1
    
    simulate_initialization
    sleep 1
    
    simulate_completion
}

# Help message
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Surge Setup Demo Script"
    echo ""
    echo "This script simulates the './surge setup' command for demonstration"
    echo "purposes. All configuration values and paths are sanitized."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "The demo will show:"
    echo "  - Welcome and prerequisites check"
    echo "  - Installation type selection (Auto/Custom)"
    echo "  - Auto setup wizard with essential questions"
    echo "  - Configuration file generation"
    echo "  - Directory structure initialization"
    echo "  - Completion with next steps"
    echo ""
    echo "Runtime: ~60-90 seconds"
    exit 0
fi

main "$@"
