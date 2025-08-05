#!/bin/bash

# ===========================================
# SURGE UPDATE MONITOR SERVICE INSTALLER
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SERVICE_NAME="surge-update-monitor"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

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

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

install_service() {
    print_info "Installing Surge update monitor service..."
    
    # Check if template exists
    local template_file="$SCRIPT_DIR/surge-update-monitor.service.template"
    if [ ! -f "$template_file" ]; then
        print_error "Service template not found: $template_file"
        exit 1
    fi
    
    # Create service file with proper paths
    sed "s|%PROJECT_DIR%|$PROJECT_DIR|g" "$template_file" > "$SERVICE_FILE"
    
    # Set proper permissions
    chmod 644 "$SERVICE_FILE"
    
    # Reload systemd and enable service
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    
    print_success "Service installed and enabled"
    print_info "Service file: $SERVICE_FILE"
}

uninstall_service() {
    print_info "Uninstalling Surge update monitor service..."
    
    # Stop and disable service
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        systemctl stop "$SERVICE_NAME"
        print_info "Service stopped"
    fi
    
    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        systemctl disable "$SERVICE_NAME"
        print_info "Service disabled"
    fi
    
    # Remove service file
    if [ -f "$SERVICE_FILE" ]; then
        rm -f "$SERVICE_FILE"
        print_info "Service file removed"
    fi
    
    # Reload systemd
    systemctl daemon-reload
    systemctl reset-failed "$SERVICE_NAME" 2>/dev/null || true
    
    print_success "Service uninstalled"
}

start_service() {
    print_info "Starting Surge update monitor service..."
    
    if [ ! -f "$SERVICE_FILE" ]; then
        print_error "Service not installed. Run: $0 install"
        exit 1
    fi
    
    systemctl start "$SERVICE_NAME"
    sleep 2
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        print_success "Service started successfully"
        show_status
    else
        print_error "Failed to start service"
        print_info "Check logs: journalctl -u $SERVICE_NAME"
        exit 1
    fi
}

stop_service() {
    print_info "Stopping Surge update monitor service..."
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        systemctl stop "$SERVICE_NAME"
        print_success "Service stopped"
    else
        print_warning "Service is not running"
    fi
}

restart_service() {
    print_info "Restarting Surge update monitor service..."
    
    if [ ! -f "$SERVICE_FILE" ]; then
        print_error "Service not installed. Run: $0 install"
        exit 1
    fi
    
    systemctl restart "$SERVICE_NAME"
    sleep 2
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        print_success "Service restarted successfully"
        show_status
    else
        print_error "Failed to restart service"
        print_info "Check logs: journalctl -u $SERVICE_NAME"
        exit 1
    fi
}

show_status() {
    print_info "Service status:"
    systemctl status "$SERVICE_NAME" --no-pager -l
    
    print_info "Recent logs:"
    journalctl -u "$SERVICE_NAME" --no-pager -n 10
}

configure_environment() {
    print_info "Configuring update monitor environment..."
    
    # Load .env if it exists
    if [ -f "$PROJECT_DIR/.env" ]; then
        source "$PROJECT_DIR/.env"
    fi
    
    echo "Current configuration:"
    echo "  Check Interval: ${UPDATE_CHECK_INTERVAL:-3600} seconds"
    echo "  Notifications: ${UPDATE_NOTIFICATIONS:-true}"
    echo "  Discord Webhook: ${DISCORD_WEBHOOK_URL:+Configured}"
    echo ""
    
    read -p "Do you want to modify these settings? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Check interval in seconds (default: 3600): " interval
        read -p "Enable notifications (true/false, default: true): " notifications
        read -p "Discord webhook URL (optional): " webhook
        
        # Update .env file
        local env_file="$PROJECT_DIR/.env"
        
        # Create .env if it doesn't exist
        if [ ! -f "$env_file" ]; then
            touch "$env_file"
        fi
        
        # Update or add settings
        if [ -n "$interval" ]; then
            if grep -q "^UPDATE_CHECK_INTERVAL=" "$env_file"; then
                sed -i "s/^UPDATE_CHECK_INTERVAL=.*/UPDATE_CHECK_INTERVAL=$interval/" "$env_file"
            else
                echo "UPDATE_CHECK_INTERVAL=$interval" >> "$env_file"
            fi
        fi
        
        if [ -n "$notifications" ]; then
            if grep -q "^UPDATE_NOTIFICATIONS=" "$env_file"; then
                sed -i "s/^UPDATE_NOTIFICATIONS=.*/UPDATE_NOTIFICATIONS=$notifications/" "$env_file"
            else
                echo "UPDATE_NOTIFICATIONS=$notifications" >> "$env_file"
            fi
        fi
        
        if [ -n "$webhook" ]; then
            if grep -q "^DISCORD_WEBHOOK_URL=" "$env_file"; then
                sed -i "s|^DISCORD_WEBHOOK_URL=.*|DISCORD_WEBHOOK_URL=$webhook|" "$env_file"
            else
                echo "DISCORD_WEBHOOK_URL=$webhook" >> "$env_file"
            fi
        fi
        
        print_success "Configuration updated"
        
        # Restart service if it's running
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            print_info "Restarting service to apply new configuration..."
            systemctl restart "$SERVICE_NAME"
        fi
    fi
}

show_help() {
    echo "Surge Update Monitor Service Management"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  install     - Install and enable the systemd service"
    echo "  uninstall   - Stop, disable and remove the service"
    echo "  start       - Start the service"
    echo "  stop        - Stop the service"
    echo "  restart     - Restart the service"
    echo "  status      - Show service status and logs"
    echo "  configure   - Configure update monitor settings"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  sudo $0 install     # Install the service"
    echo "  sudo $0 start       # Start monitoring"
    echo "  sudo $0 status      # Check if running"
    echo "  sudo $0 configure   # Configure settings"
    echo ""
}

# Main function
main() {
    case ${1:-} in
        install)
            check_root
            install_service
            ;;
        uninstall)
            check_root
            uninstall_service
            ;;
        start)
            check_root
            start_service
            ;;
        stop)
            check_root
            stop_service
            ;;
        restart)
            check_root
            restart_service
            ;;
        status)
            show_status
            ;;
        configure)
            configure_environment
            ;;
        help|-h|--help)
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
