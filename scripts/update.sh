#!/bin/bash

# ===========================================
# SURGE UPDATE SCRIPT
# Enhanced with monitoring integration
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Check for available updates first
check_updates() {
    print_step "Checking for available updates..."
    
    if command -v python3 >/dev/null 2>&1; then
        if python3 "$SCRIPT_DIR/update-monitor.py" --check-once >/dev/null 2>&1; then
            print_info "No updates detected"
            return 1
        else
            print_info "Updates are available"
            return 0
        fi
    else
        print_warning "Python3 not available, skipping update check"
        return 0
    fi
}

# Preserve user configurations during update
preserve_configs() {
    print_step "Preserving user configurations..."
    
    # Create temporary backup of important config files
    local temp_backup="/tmp/surge_config_backup_$(date +%s)"
    mkdir -p "$temp_backup"
    
    # Backup .env file
    if [ -f "$PROJECT_DIR/.env" ]; then
        cp "$PROJECT_DIR/.env" "$temp_backup/"
        print_info "Backed up .env file"
    fi
    
    # Backup any custom configuration files that shouldn't be overwritten
    if [ -d "$PROJECT_DIR/config" ]; then
        # Only backup files that contain user settings, not empty templates
        find "$PROJECT_DIR/config" -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.ini" | while read -r config_file; do
            if [ -s "$config_file" ]; then  # Only if file is not empty
                rel_path="${config_file#$PROJECT_DIR/}"
                backup_dir="$temp_backup/$(dirname "$rel_path")"
                mkdir -p "$backup_dir"
                cp "$config_file" "$backup_dir/"
            fi
        done
        print_info "Backed up user configuration files"
    fi
    
    echo "$temp_backup"
}

# Restore user configurations after update
restore_configs() {
    local backup_dir="$1"
    
    if [ -d "$backup_dir" ]; then
        print_step "Restoring user configurations..."
        
        # Restore .env
        if [ -f "$backup_dir/.env" ]; then
            cp "$backup_dir/.env" "$PROJECT_DIR/"
            print_info "Restored .env file"
        fi
        
        # Restore config files
        if [ -d "$backup_dir/config" ]; then
            cp -r "$backup_dir/config"/* "$PROJECT_DIR/config/" 2>/dev/null || true
            print_info "Restored configuration files"
        fi
        
        # Clean up temporary backup
        rm -rf "$backup_dir"
        print_info "Cleaned up temporary backup"
    fi
}

# Send Discord notification about update
send_update_notification() {
    local status="$1"
    local message="$2"
    
    if [ -n "$DISCORD_WEBHOOK_URL" ] && command -v curl >/dev/null 2>&1; then
        local color="3066993"  # Green
        local emoji="✅"
        
        if [ "$status" = "error" ]; then
            color="15158332"  # Red
            emoji="❌"
        elif [ "$status" = "warning" ]; then
            color="15105570"  # Orange
            emoji="⚠️"
        fi
        
        local payload=$(cat <<EOF
{
  "avatar_url": "https://raw.githubusercontent.com/amcgready/Surge/main/assets/Surge.png",
  "embeds": [
    {
      "title": "${emoji} Surge Update ${status^}",
      "description": "$message",
      "color": $color,
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
      "footer": {
        "text": "Surge Media Stack"
      }
    }
  ]
}
EOF
)
        
        curl -X POST "$DISCORD_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "$payload" \
             --silent --show-error || true
    fi
}

# Update function
update_surge() {
    print_info "Starting Surge update process..."
    
    cd "$PROJECT_DIR"
    
    # Preserve configurations
    local backup_dir
    backup_dir=$(preserve_configs)
    
    local update_failed=false
    
    # Pull latest images
    print_step "Pulling latest container images..."
    if docker compose pull; then
        print_success "Successfully pulled latest images"
    else
        print_error "Failed to pull some images"
        update_failed=true
    fi
    
    # Recreate containers with new images (only if pull succeeded)
    if [ "$update_failed" = false ]; then
        print_step "Selecting enabled services from .env..."
        # Parse enabled services from .env
        # Get all service names from docker-compose.yml
        compose_services=($(grep -E '^  [a-zA-Z0-9_-]+:' "$PROJECT_DIR/docker-compose.yml" | awk '{print $1}' | tr -d ':'))
        enabled_services=()
        while IFS= read -r line; do
            if [[ $line =~ ^ENABLE_([A-Z0-9_]+)=true ]]; then
                env_name="${BASH_REMATCH[1],,}"
                # Map env_name to service name
                case "$env_name" in
                    cli_debrid)
                        service_name="cli-debrid" ;;
                    rdt_client)
                        service_name="rdt-client" ;;
                    *)
                        service_name="$env_name" ;;
                esac
                # Only add if service exists in compose file
                if [[ " ${compose_services[@]} " =~ " $service_name " ]]; then
                    enabled_services+=("$service_name")
                fi
            fi
        done < "$PROJECT_DIR/.env"
        if [ ${#enabled_services[@]} -eq 0 ]; then
            print_error "No enabled services found in .env that exist in docker-compose.yml. Aborting update."
            update_failed=true
        else
            print_step "Recreating enabled containers: ${enabled_services[*]}"
            if docker compose up -d "${enabled_services[@]}"; then
                print_success "Successfully recreated enabled containers"
            else
                print_error "Failed to recreate enabled containers"
                update_failed=true
            fi
        fi
    fi
    
    # Restore configurations
    restore_configs "$backup_dir"
    
    # Wait for containers to be healthy
    if [ "$update_failed" = false ]; then
        print_step "Waiting for containers to be healthy..."
        sleep 10
        
        # Check container health
        local unhealthy_containers
        unhealthy_containers=$(docker compose ps --format json | jq -r 'select(.Health == "unhealthy" or .State == "exited") | .Service' 2>/dev/null || echo "")
        
        if [ -n "$unhealthy_containers" ]; then
            print_warning "Some containers may not be healthy:"
            echo "$unhealthy_containers"
            send_update_notification "warning" "Update completed but some containers may need attention: $unhealthy_containers"
        else
            print_success "All containers are healthy"
            send_update_notification "success" "Surge update completed successfully! All containers are running normally."
        fi
    else
        send_update_notification "error" "Surge update failed during container update process. Please check logs and try again."
        return 1
    fi
    
    # Clean up old images (optional)
    if [ "$cleanup" = true ]; then
        print_step "Cleaning up old Docker images..."
        if docker image prune -f >/dev/null 2>&1; then
            print_success "Cleaned up old images"
        else
            print_warning "Could not clean up some old images"
        fi
    fi
    
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
    echo "  --check           - Check for updates without applying them"
    echo "  --force           - Force update even if no updates detected"
    echo "  --backup          - Create configuration backup before update"
    echo "  --no-cleanup      - Skip cleanup of old Docker images"
    echo "  --monitor-start   - Start the update monitoring service"
    echo "  --monitor-stop    - Stop the update monitoring service"
    echo "  --monitor-status  - Check update monitoring service status"
    echo "  -h, --help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                # Check and apply updates if available"
    echo "  $0 --check        # Only check for updates"
    echo "  $0 --force        # Force update regardless of detection"
    echo "  $0 --monitor-start # Start background monitoring service"
    echo ""
}

# Monitor management functions
start_monitor() {
    print_info "Starting update monitor service..."
    
    local log_file="${SURGE_LOG_FILE:-/var/log/surge-update-monitor.log}"
    
    if command -v python3 >/dev/null 2>&1; then
        # Check if already running
        if pgrep -f "update-monitor.py.*daemon" >/dev/null; then
            print_warning "Update monitor is already running"
            return 0
        fi
        
        # Start the monitor in background
        nohup python3 "$SCRIPT_DIR/update-monitor.py" --daemon >"$log_file" 2>&1 &
        echo $! > /var/run/surge-update-monitor.pid
        
        sleep 2
        if pgrep -f "update-monitor.py.*daemon" >/dev/null; then
            print_success "Update monitor started successfully"
            print_info "Logs: $log_file"
        else
            print_error "Failed to start update monitor"
            return 1
        fi
    else
        print_error "Python3 is required for update monitoring"
        return 1
    fi
}

stop_monitor() {
    print_info "Stopping update monitor service..."
    
    if [ -f /var/run/surge-update-monitor.pid ]; then
        local pid=$(cat /var/run/surge-update-monitor.pid)
        if kill "$pid" 2>/dev/null; then
            rm -f /var/run/surge-update-monitor.pid
            print_success "Update monitor stopped"
        else
            print_warning "Update monitor PID file exists but process not found"
            rm -f /var/run/surge-update-monitor.pid
        fi
    else
        # Try to kill by process name
        if pkill -f "update-monitor.py.*daemon"; then
            print_success "Update monitor stopped"
        else
            print_warning "No running update monitor found"
        fi
    fi
}

monitor_status() {
    if pgrep -f "update-monitor.py.*daemon" >/dev/null; then
        local pid=$(pgrep -f "update-monitor.py.*daemon")
        print_success "Update monitor is running (PID: $pid)"
        
        # Show last few log lines if available
        local log_file="${SURGE_LOG_FILE:-/var/log/surge-update-monitor.log}"
        if [ -f "$log_file" ]; then
            print_info "Recent monitor activity:"
            tail -5 "$log_file"
        fi
    else
        print_warning "Update monitor is not running"
        return 1
    fi
}

# Main function
main() {
    local create_backup=false
    local cleanup=true
    local check_only=false
    local force_update=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                check_only=true
                shift
                ;;
            --force)
                force_update=true
                shift
                ;;
            --backup)
                create_backup=true
                shift
                ;;
            --no-cleanup)
                cleanup=false
                shift
                ;;
            --monitor-start)
                start_monitor
                exit $?
                ;;
            --monitor-stop)
                stop_monitor
                exit $?
                ;;
            --monitor-status)
                monitor_status
                exit $?
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
    
    # Check for updates first (unless forced)
    if [ "$force_update" = false ]; then
        if ! check_updates; then
            if [ "$check_only" = true ]; then
                print_success "No updates available"
                exit 0
            else
                print_info "No updates detected. Use --force to update anyway."
                exit 0
            fi
        fi
    fi
    
    # If only checking, report updates found
    if [ "$check_only" = true ]; then
        print_warning "Updates are available!"
        print_info "Run './surge --update' to apply updates"
        exit 1
    fi
    
    # Create backup if requested
    if [ "$create_backup" = true ]; then
        backup_configs
    fi
    
    # Run update
    update_surge
}

# Run main function
main "$@"
