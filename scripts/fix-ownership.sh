#!/bin/bash

# ===========================================
# SURGE OWNERSHIP FIX SCRIPT
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

# Fix ownership for storage directories
fix_ownership() {
    local storage_path=${1:-"/opt/surge"}
    
    print_info "Fixing ownership for storage path: $storage_path"
    
    if [ ! -d "$storage_path" ]; then
        print_error "Storage path does not exist: $storage_path"
        exit 1
    fi
    
    # Try to read PUID and PGID from .env file
    local puid=1000
    local pgid=1000
    
    if [ -f "$PROJECT_DIR/.env" ]; then
        # Source the .env file to get PUID/PGID
        eval "$(grep -E '^(PUID|PGID)=' "$PROJECT_DIR/.env" | sed 's/^/export /')"
        puid=${PUID:-1000}
        pgid=${PGID:-1000}
        print_info "Using PUID:PGID from .env file: $puid:$pgid"
    else
        print_info "No .env file found, using default PUID:PGID: $puid:$pgid"
    fi
    
    # Check if running as root
    if [ "$(id -u)" -eq 0 ]; then
        print_info "Running as root, setting ownership directly..."
        chown -R "$puid:$pgid" "$storage_path"
        print_success "Ownership set to $puid:$pgid for $storage_path"
    else
        print_info "Not running as root, attempting to use sudo..."
        
        # Check if sudo is available without password
        if sudo -n true 2>/dev/null; then
            print_info "Sudo available, setting ownership..."
            sudo chown -R "$puid:$pgid" "$storage_path"
            print_success "Ownership set to $puid:$pgid for $storage_path (with sudo)"
        else
            print_warning "Sudo authentication required..."
            echo "This script needs to set ownership of directories to $puid:$pgid to match"
            echo "the PUID:PGID used by Docker containers. Please enter your password:"
            
            if sudo chown -R "$puid:$pgid" "$storage_path"; then
                print_success "Ownership set to $puid:$pgid for $storage_path (with sudo)"
            else
                print_error "Failed to set ownership. Please run manually:"
                print_error "  sudo chown -R $puid:$pgid $storage_path"
                exit 1
            fi
        fi
    fi
    
    # Verify ownership was set correctly
    owner=$(stat -c '%U:%G' "$storage_path" 2>/dev/null || echo "unknown")
    target_owner="$puid:$pgid"
    
    # Also check if owner matches the actual usernames
    if [ "$owner" = "$target_owner" ] || [ "$owner" = "$(id -un $puid 2>/dev/null):$(id -gn $pgid 2>/dev/null)" ]; then
        print_success "Ownership verification successful: $owner"
    else
        print_warning "Ownership verification failed. Current owner: $owner, Expected: $target_owner"
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [STORAGE_PATH]"
    echo ""
    echo "Fix ownership of Surge storage directories to match Docker container PUID:PGID (1000:1000)"
    echo ""
    echo "Arguments:"
    echo "  STORAGE_PATH  Path to storage directory (default: /opt/surge)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Fix ownership for /opt/surge"
    echo "  $0 /mnt/surge         # Fix ownership for custom path"
    echo "  $0 \$STORAGE_PATH     # Fix ownership using environment variable"
}

# Main function
main() {
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        "")
            # No arguments, try to read from .env file
            if [ -f "$PROJECT_DIR/.env" ]; then
                STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "")
                STORAGE_PATH=$(eval echo "$STORAGE_PATH")  # Expand variables
            fi
            fix_ownership "${STORAGE_PATH:-/opt/surge}"
            ;;
        *)
            # Storage path provided as argument
            STORAGE_PATH=$(eval echo "$1")  # Expand variables like $HOME
            fix_ownership "$STORAGE_PATH"
            ;;
    esac
}

# Run main function
main "$@"
