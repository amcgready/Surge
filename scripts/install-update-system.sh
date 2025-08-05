#!/bin/bash

# ===========================================
# SURGE UPDATE SYSTEM INSTALLER
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

install_python_deps() {
    print_info "Installing Python dependencies for update monitoring..."
    
    # Check if pip is available
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install requests
        print_success "Python dependencies installed"
    elif command -v pip >/dev/null 2>&1; then
        pip install requests
        print_success "Python dependencies installed"
    else
        print_warning "pip not found. Trying package manager..."
        
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update
            apt-get install -y python3-requests
        elif command -v yum >/dev/null 2>&1; then
            yum install -y python3-requests
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y python3-requests
        elif command -v pacman >/dev/null 2>&1; then
            pacman -S --noconfirm python-requests
        else
            print_error "Could not install Python requests module"
            print_info "Please install manually: pip3 install requests"
            return 1
        fi
        print_success "Python dependencies installed via package manager"
    fi
}

setup_log_directory() {
    print_info "Setting up log directory..."
    
    # Create log directory
    if mkdir -p /var/log 2>/dev/null; then
        # Set permissions for surge update monitor log
        touch /var/log/surge-update-monitor.log 2>/dev/null || true
        chmod 644 /var/log/surge-update-monitor.log 2>/dev/null || true
        print_success "Log directory configured"
    else
        print_warning "Could not setup system log directory"
        print_info "Update monitor will use console logging only"
    fi
}

test_update_system() {
    print_info "Testing update system..."
    
    # Test basic functionality
    if python3 "$SCRIPT_DIR/update-monitor.py" --help >/dev/null 2>&1; then
        print_success "Update monitor is functional"
    else
        print_error "Update monitor test failed"
        return 1
    fi
    
    # Test update script
    if "$SCRIPT_DIR/update.sh" --help >/dev/null 2>&1; then
        print_success "Update script is functional"
    else
        print_error "Update script test failed"
        return 1
    fi
    
    # Test Discord notification capability
    if python3 -c "import requests" 2>/dev/null; then
        print_success "Discord notifications available"
    else
        print_warning "Discord notifications disabled (requests module missing)"
    fi
}

show_completion_info() {
    echo ""
    echo "🎉 Surge Update System Installation Complete!"
    echo ""
    echo "Available Commands:"
    echo "  ./surge --update              - Check and apply updates"
    echo "  ./surge --update --check      - Check for updates only"
    echo "  ./surge --update --monitor-start - Start background monitoring"
    echo ""
    echo "Service Installation (optional):"
    echo "  sudo ./scripts/update-service.sh install"
    echo "  sudo ./scripts/update-service.sh start"
    echo ""
    echo "Configuration:"
    echo "  Edit .env to add DISCORD_WEBHOOK_URL for notifications"
    echo "  Set UPDATE_CHECK_INTERVAL for custom check frequency"
    echo ""
    echo "Documentation:"
    echo "  See docs/container-updates.md for complete guide"
    echo ""
}

main() {
    echo "🔄 Installing Surge Update System..."
    echo ""
    
    # Check if running as root for some operations
    if [ "$EUID" -eq 0 ]; then
        print_info "Running as root - full installation available"
        FULL_INSTALL=true
    else
        print_info "Running as user - limited installation"
        FULL_INSTALL=false
    fi
    
    # Install Python dependencies
    if [ "$FULL_INSTALL" = true ]; then
        install_python_deps
    else
        print_info "Checking Python dependencies..."
        if python3 -c "import requests" 2>/dev/null; then
            print_success "Python dependencies already available"
        else
            print_warning "Python 'requests' module missing"
            print_info "Install with: pip3 install requests"
            print_info "Or run this installer as root for automatic installation"
        fi
    fi
    
    # Setup logging
    if [ "$FULL_INSTALL" = true ]; then
        setup_log_directory
    else
        print_info "Skipping log directory setup (requires root)"
    fi
    
    # Test system
    test_update_system
    
    # Show completion info
    show_completion_info
    
    if [ "$FULL_INSTALL" = false ]; then
        echo "💡 Tip: Run with sudo for complete installation:"
        echo "   sudo $0"
        echo ""
    fi
}

# Show help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Surge Update System Installer"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "This script installs and configures the Surge container update system."
    echo "Run as root for complete installation including Python dependencies."
    echo ""
    exit 0
fi

main "$@"
