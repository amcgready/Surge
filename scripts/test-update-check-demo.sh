#!/bin/bash

# ===========================================
# SURGE UPDATE CHECK DEMO SCRIPT
# ===========================================
# Simulates ./surge --update --check

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    printf "  🌊 Update Checker\n"
    printf "\n"
}

simulate_update_check() {
    print_banner
    
    echo -e "${YELLOW}Checking for Surge Updates${NC}"
    echo ""
    print_step "Checking for available updates..."
    echo ""
    
    print_info "Scanning Docker Hub for latest image versions..."
    sleep 2
    
    echo ""
    echo "📋 Update Status Report:"
    echo ""
    echo "  ┌─ Container Images"
    echo "  ├─ 🔄 linuxserver/radarr"
    echo "  │    Current: v4.7.5.7809"
    echo "  │    Latest:  v4.8.0.7850"
    echo "  │    Status:  Update available"
    echo "  │"
    echo "  ├─ 🔄 linuxserver/sonarr"
    echo "  │    Current: v3.0.10.1567"
    echo "  │    Latest:  v3.0.11.1675"
    echo "  │    Status:  Update available"
    echo "  │"
    echo "  ├─ 🔄 linuxserver/prowlarr"
    echo "  │    Current: v1.10.5.4116"
    echo "  │    Latest:  v1.11.0.4204"
    echo "  │    Status:  Update available"
    echo "  │"
    echo "  ├─ 🔄 linuxserver/bazarr"
    echo "  │    Current: v1.4.0"
    echo "  │    Latest:  v1.4.1"
    echo "  │    Status:  Update available"
    echo "  │"
    echo "  ├─ ✅ linuxserver/overseerr"
    echo "  │    Current: v1.33.2"
    echo "  │    Latest:  v1.33.2"
    echo "  │    Status:  Up to date"
    echo "  │"
    echo "  ├─ 🔄 plexinc/pms-docker"
    echo "  │    Current: v1.32.7.7621"
    echo "  │    Latest:  v1.32.8.7639"
    echo "  │    Status:  Update available"
    echo "  │"
    echo "  ├─ ✅ linuxserver/homepage"
    echo "  │    Current: v0.8.10"
    echo "  │    Latest:  v0.8.10"
    echo "  │    Status:  Up to date"
    echo "  │"
    echo "  └─ ✅ cinesync/cinesync"
    echo "       Current: v2.1.0"
    echo "       Latest:  v2.1.0"
    echo "       Status:  Up to date"
    echo ""
    
    sleep 3
    
    echo "📊 Summary:"
    echo "  ├─ Total containers: 8"
    echo "  ├─ Updates available: 5"
    echo "  ├─ Up to date: 3"
    echo "  └─ Estimated download: ~2.1 GB"
    echo ""
    
    print_warning "Updates are available!"
    echo ""
    print_info "💡 To apply updates, run:"
    echo "     ./surge --update"
    echo ""
    print_info "💡 To force update all containers:"
    echo "     ./surge --update --force"
    echo ""
    print_info "💡 To create backup before updating:"
    echo "     ./surge --update --backup"
    echo ""
    
    print_info "🔔 Update notifications:"
    echo "  └─ Discord webhook configured - you'll be notified when updates complete"
    echo ""
    
    sleep 2
    print_success "Update check completed!"
}

# Help message
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Surge Update Check Demo Script"
    echo ""
    echo "This script simulates the './surge --update --check' command for"
    echo "demonstration purposes. Shows available updates without applying them."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "The demo will show:"
    echo "  - Docker Hub scanning for updates"
    echo "  - Detailed per-container update status"
    echo "  - Version comparisons (current vs latest)"
    echo "  - Update summary and next steps"
    echo ""
    echo "Runtime: ~30 seconds"
    exit 0
fi

simulate_update_check
