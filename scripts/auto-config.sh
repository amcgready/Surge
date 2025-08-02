#!/bin/bash

# Surge Auto-Configuration Tool
# Automatically discovers and configures service connections

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${PURPLE}=====================================${NC}"
    echo -e "${PURPLE}    Surge Auto-Configuration Tool    ${NC}"
    echo -e "${PURPLE}=====================================${NC}"
    echo ""
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Automatically discover and configure service connections in Surge"
    echo ""
    echo "Options:"
    echo "  --storage-path PATH    Set storage path (default: from .env)"
    echo "  --service SERVICE      Configure specific service only"
    echo "  --discover-only        Only discover API keys, don't configure"
    echo "  --wait-timeout SEC     How long to wait for services (default: 300)"
    echo "  --help                 Show this help message"
    echo ""
    echo "Services:"
    echo "  bazarr                 Configure Bazarr connections"
    echo "  gaps                   Configure GAPS connections"
    echo "  overseerr              Configure Overseerr connections"
    echo "  placeholdarr           Configure Placeholdarr connections"
    echo "  all                    Configure all services (default)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Configure all services"
    echo "  $0 --service bazarr                  # Configure only Bazarr"
    echo "  $0 --discover-only                   # Just show discovered API keys"
    echo "  $0 --storage-path /custom/path       # Use custom storage path"
}

# Load environment variables
load_env() {
    if [ -f "$PROJECT_DIR/.env" ]; then
        set -a
        source "$PROJECT_DIR/.env"
        set +a
    fi
}

# Check if services are running
check_services() {
    print_info "Checking service status..."
    
    local services=("surge-radarr" "surge-sonarr" "surge-prowlarr")
    local running_services=()
    local missing_services=()
    
    for service in "${services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "^$service$"; then
            running_services+=("$service")
        else
            missing_services+=("$service")
        fi
    done
    
    if [ ${#running_services[@]} -gt 0 ]; then
        print_success "Running services: ${running_services[*]}"
    fi
    
    if [ ${#missing_services[@]} -gt 0 ]; then
        print_warning "Not running: ${missing_services[*]}"
        print_info "Only running services will be configured"
    fi
    
    if [ ${#running_services[@]} -eq 0 ]; then
        print_error "No core services are running. Please start Surge services first."
        echo "Run: ./surge deploy <media-server>"
        exit 1
    fi
}

# Wait for services to be ready
wait_for_services() {
    local timeout=${1:-300}
    print_info "Waiting for services to be ready (timeout: ${timeout}s)..."
    
    local start_time=$(date +%s)
    local services=("7878" "8989" "9696")  # Radarr, Sonarr, Prowlarr ports
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -ge $timeout ]; then
            print_warning "Timeout reached. Some services may not be ready."
            break
        fi
        
        local ready_count=0
        
        for port in "${services[@]}"; do
            if curl -s "http://localhost:$port/api/v3/system/status" >/dev/null 2>&1 || \
               curl -s "http://localhost:$port/api/v1/system/status" >/dev/null 2>&1; then
                ((ready_count++))
            fi
        done
        
        if [ $ready_count -eq ${#services[@]} ]; then
            print_success "All services are ready!"
            return 0
        fi
        
        echo -n "."
        sleep 5
    done
    
    echo ""
    return 1
}

# Discover API keys using Python script
discover_api_keys() {
    local storage_path=$1
    local python_script="$SCRIPT_DIR/api-discovery.py"
    
    if [ ! -f "$python_script" ]; then
        print_error "API discovery script not found: $python_script"
        return 1
    fi
    
    print_info "Discovering API keys..."
    
    if command -v python3 >/dev/null 2>&1; then
        python3 "$python_script" --storage-path "$storage_path" --discover-only
    else
        print_error "Python 3 is required for API discovery"
        return 1
    fi
}

# Run auto-configuration using Python script
run_auto_config() {
    local storage_path=$1
    local service=$2
    local python_script="$SCRIPT_DIR/api-discovery.py"
    
    if [ ! -f "$python_script" ]; then
        print_error "API discovery script not found: $python_script"
        return 1
    fi
    
    print_info "Running auto-configuration..."
    
    local args=("--storage-path" "$storage_path")
    
    if [ -n "$service" ] && [ "$service" != "all" ]; then
        args+=("--service" "$service")
    fi
    
    if command -v python3 >/dev/null 2>&1; then
        python3 "$python_script" "${args[@]}"
        return $?
    else
        print_error "Python 3 is required for auto-configuration"
        return 1
    fi
}

# Main function
main() {
    local storage_path=""
    local service="all"
    local discover_only=false
    local wait_timeout=300
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --storage-path)
                storage_path="$2"
                shift 2
                ;;
            --service)
                service="$2"
                shift 2
                ;;
            --discover-only)
                discover_only=true
                shift
                ;;
            --wait-timeout)
                wait_timeout="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_header
    
    # Load environment
    load_env
    
    # Set default storage path
    if [ -z "$storage_path" ]; then
        storage_path="${STORAGE_PATH:-/opt/surge}"
    fi
    
    print_info "Using storage path: $storage_path"
    
    # Check if services are running
    check_services
    
    # Wait for services to be ready
    wait_for_services "$wait_timeout"
    
    # Run discovery or configuration
    if [ "$discover_only" = true ]; then
        discover_api_keys "$storage_path"
    else
        if run_auto_config "$storage_path" "$service"; then
            print_success "Auto-configuration completed successfully!"
            echo ""
            echo "🎉 Your services should now be connected automatically!"
            echo ""
            echo "What was configured:"
            echo "• Bazarr ↔ Radarr/Sonarr connections"
            echo "• GAPS ↔ Radarr connection"
            echo "• Overseerr ↔ Radarr/Sonarr configuration prepared"
            echo "• Placeholdarr ↔ Radarr/Sonarr connections"
            echo ""
            echo "💡 Some services may require a restart to pick up new configurations."
        else
            print_error "Auto-configuration failed"
            exit 1
        fi
    fi
}

# Run main function
main "$@"
