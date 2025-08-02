#!/bin/bash

# ===========================================
# RESTART BAZARR TO PICK UP NEW CONFIGURATION
# ===========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

cd "$PROJECT_DIR"

print_info "Restarting Bazarr to pick up new configuration..."
docker compose restart bazarr

print_success "Bazarr restarted! Check http://localhost:6767 to verify Radarr and Sonarr connections."
print_info "💡 Go to Settings → Sonarr/Radarr in Bazarr to see the configured connections"
