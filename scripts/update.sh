#!/bin/bash

# ===========================================
# SURGE UPDATE SCRIPT
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

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

# Update function
update_surge() {
    print_info "Starting Surge update process..."
    
    cd "$PROJECT_DIR"
    
    # Pull latest images
    print_info "Pulling latest container images..."
    docker compose pull
    
    # Recreate containers with new images
    print_info "Recreating containers with latest images..."
    docker compose up -d
    
    # Clean up old images
    print_info "Cleaning up old Docker images..."
    docker image prune -f
    
    print_success "Surge update completed successfully!"
}

# Backup function
backup_configs() {
    print_info "Creating configuration backup..."
    
    local backup_dir="$PROJECT_DIR/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup .env file
    if [ -f "$PROJECT_DIR/.env" ]; then
        cp "$PROJECT_DIR/.env" "$backup_dir/"
    fi
    
    # Backup Docker volumes (configs only)
    docker run --rm -v surge_radarr-config:/volume -v "$backup_dir":/backup alpine tar czf /backup/radarr-config.tar.gz -C /volume .
    docker run --rm -v surge_sonarr-config:/volume -v "$backup_dir":/backup alpine tar czf /backup/sonarr-config.tar.gz -C /volume .
    docker run --rm -v surge_bazarr-config:/volume -v "$backup_dir":/backup alpine tar czf /backup/bazarr-config.tar.gz -C /volume .
    
    print_success "Backup created at $backup_dir"
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --backup      - Create configuration backup before update"
    echo "  --no-cleanup  - Skip cleanup of old Docker images"
    echo "  -h, --help    - Show this help message"
    echo ""
}

# Main function
main() {
    local create_backup=false
    local cleanup=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --backup)
                create_backup=true
                shift
                ;;
            --no-cleanup)
                cleanup=false
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Create backup if requested
    if [ "$create_backup" = true ]; then
        backup_configs
    fi
    
    # Run update
    update_surge
}

# Run main function
main "$@"
