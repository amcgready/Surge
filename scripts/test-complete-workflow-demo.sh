#!/bin/bash

# ===========================================
# SURGE COMPLETE WORKFLOW DEMO SCRIPT
# ===========================================
# Demonstrates the complete Surge workflow:
# setup → deploy → configure

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
    printf "  🌊 Complete Workflow Demo\n"
    printf "\n"
}

simulate_complete_workflow() {
    print_banner
    
    echo -e "${YELLOW}Surge Complete Workflow Demo${NC}"
    echo ""
    echo "This demo shows the complete Surge experience:"
    echo "  1. Initial setup (./surge setup)"
    echo "  2. Stack deployment (./surge deploy plex)"
    echo "  3. Service configuration (./surge auto-config)"
    echo ""
    sleep 3
    
    # Phase 1: Setup
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_step "Phase 1: Initial Setup (./surge setup)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sleep 1
    
    print_info "🔍 Checking prerequisites..."
    echo "  ✓ Docker ✓ Compose ✓ Storage"
    sleep 1
    
    print_info "🚀 Running auto install..."
    echo "  ├─ Media Server: Plex"
    echo "  ├─ Storage: /home/user/surge-media"
    echo "  └─ Services: Full stack"
    sleep 2
    
    print_success "Setup complete! Configuration generated."
    echo ""
    sleep 1
    
    # Phase 2: Deployment
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_step "Phase 2: Stack Deployment (./surge deploy plex)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sleep 1
    
    print_info "🐳 Pulling Docker images..."
    echo "  prowlarr, radarr, sonarr, bazarr, plex..."
    sleep 2
    
    print_info "⚡ Starting services..."
    local services=("prowlarr" "radarr" "sonarr" "bazarr" "overseerr" "plex" "homepage")
    for service in "${services[@]}"; do
        echo "  ├─ surge-$service: ✓ Running"
        sleep 0.3
    done
    sleep 1
    
    print_success "All services deployed and running!"
    echo ""
    sleep 1
    
    # Phase 3: Configuration
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_step "Phase 3: Auto Configuration (./surge auto-config)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sleep 1
    
    print_info "🔑 Discovering API keys..."
    echo "  ├─ Prowlarr: ****************************************"
    echo "  ├─ Radarr:   ****************************************"
    echo "  └─ Sonarr:   ****************************************"
    sleep 2
    
    print_info "🔗 Configuring connections..."
    echo "  ├─ Prowlarr → Radarr: ✓ Connected"
    echo "  ├─ Prowlarr → Sonarr: ✓ Connected"
    echo "  ├─ Bazarr → Radarr: ✓ Connected"
    echo "  └─ Bazarr → Sonarr: ✓ Connected"
    sleep 2
    
    print_info "📡 Adding default indexers..."
    echo "  ├─ 1337x: ✓ Configured"
    echo "  ├─ RARBG: ✓ Configured"
    echo "  └─ TPB: ✓ Configured"
    sleep 2
    
    print_success "Service configuration complete!"
    echo ""
    sleep 1
    
    # Final status
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "🎉 Surge is fully operational!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_info "🌐 Access your services:"
    echo "  ├─ Homepage Dashboard: http://localhost:3000"
    echo "  ├─ Plex Media Server:  http://localhost:32400/web"
    echo "  ├─ Radarr (Movies):    http://localhost:7878"
    echo "  ├─ Sonarr (TV):        http://localhost:8989"
    echo "  └─ Overseerr (Requests): http://localhost:5055"
    echo ""
    
    print_info "🚀 Ready to manage your media collection!"
    echo ""
    print_success "Complete workflow finished in under 2 minutes!"
}

# Help message
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Surge Complete Workflow Demo Script"
    echo ""
    echo "This script demonstrates the complete Surge user experience:"
    echo "  1. Initial setup wizard"
    echo "  2. Full stack deployment"
    echo "  3. Automatic service configuration"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Runtime: ~90 seconds"
    echo "Perfect for: Overview presentations, onboarding demos"
    exit 0
fi

simulate_complete_workflow
