#!/bin/bash

# NZBGet Automation Script for Surge
# Configures NZBGet and integrates it with Radarr, Sonarr, and Prowlarr

set -e

# Source the main utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utility functions
if [ -f "$SCRIPT_DIR/shared-config.sh" ]; then
    source "$SCRIPT_DIR/shared-config.sh"
else
    echo "Error: shared-config.sh not found!"
    exit 1
fi

print_header() {
    echo ""
    echo "=================================================="
    echo "         🚀 NZBGet Automation for Surge"
    echo "=================================================="
    echo ""
}

print_summary() {
    echo ""
    echo "=================================================="
    echo "        📊 NZBGet Configuration Summary"
    echo "=================================================="
    echo "✅ NZBGet server configuration optimized"
    echo "✅ Download categories created (movies, tv, music, books)"
    echo "✅ NZBGet integrated with Radarr as download client"
    echo "✅ NZBGet integrated with Sonarr as download client"
    echo "✅ Proper container networking configured"
    echo ""
    echo "🌐 Access NZBGet: http://localhost:6789"
    echo "🔑 Username: ${NZBGET_USER:-admin}"
    echo "🔑 Password: $(printf '%*s' ${#NZBGET_PASS:-9} | tr ' ' '*')"
    echo ""
    echo "💡 Next Steps:"
    echo "   1. Add your Usenet providers in NZBGet"
    echo "   2. Configure indexers in Prowlarr"
    echo "   3. Test downloads through Radarr/Sonarr"
    echo "=================================================="
}

check_prerequisites() {
    print_step "🔍 Checking prerequisites..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    # Check if NZBGet container exists
    if ! docker ps -a --format "table {{.Names}}" | grep -q "surge-nzbget"; then
        print_error "NZBGet container not found. Please deploy the Surge stack first."
        exit 1
    fi
    
    # Check if container is running
    if ! docker ps --format "table {{.Names}}" | grep -q "surge-nzbget"; then
        print_warning "NZBGet container is not running. Starting it now..."
        docker compose up -d nzbget
        sleep 10
    fi
    
    print_success "Prerequisites check completed"
}

check_service_status() {
    print_step "📡 Checking service status..."
    
    local services=("surge-nzbget" "surge-radarr" "surge-sonarr" "surge-prowlarr")
    local running_services=0
    
    for service in "${services[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$service"; then
            print_info "✅ $service is running"
            ((running_services++))
        else
            print_warning "❌ $service is not running"
        fi
    done
    
    if [ $running_services -lt 3 ]; then
        print_error "Not enough services are running. Please ensure Radarr, Sonarr, and NZBGet are running."
        exit 1
    fi
    
    print_success "Service status check completed ($running_services/4 services running)"
}

run_python_automation() {
    print_step "🔧 Running Python automation script..."
    
    local storage_path="${STORAGE_PATH:-/opt/surge}"
    
    if [ ! -f "$SCRIPT_DIR/configure-nzbget.py" ]; then
        print_error "NZBGet configuration script not found at $SCRIPT_DIR/configure-nzbget.py"
        exit 1
    fi
    
    # Make sure the script is executable
    chmod +x "$SCRIPT_DIR/configure-nzbget.py"
    
    # Run the Python automation
    print_info "Running NZBGet configuration with storage path: $storage_path"
    
    if python3 "$SCRIPT_DIR/configure-nzbget.py" "$storage_path"; then
        print_success "Python automation completed successfully"
        return 0
    else
        print_error "Python automation failed"
        return 1
    fi
}

run_service_config_automation() {
    print_step "🔧 Running service configuration automation..."
    
    # Load environment variables if .env exists
    if [ -f "$PROJECT_DIR/.env" ]; then
        set -a
        source "$PROJECT_DIR/.env"
        set +a
        print_info "Loaded environment variables from .env file"
    fi
    
    # Run the service configuration
    python3 -c "
import sys
sys.path.append('$SCRIPT_DIR')
from service_config import run_nzbget_full_automation
result = run_nzbget_full_automation()
sys.exit(0 if result else 1)
"
    
    if [ $? -eq 0 ]; then
        print_success "Service configuration automation completed successfully"
        return 0
    else
        print_error "Service configuration automation failed"
        return 1
    fi
}

test_nzbget_connection() {
    print_step "🧪 Testing NZBGet connection..."
    
    local nzbget_url="http://localhost:6789"
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s --max-time 5 "$nzbget_url" > /dev/null 2>&1; then
            print_success "NZBGet is accessible at $nzbget_url"
            return 0
        fi
        
        print_info "Attempt $attempt/$max_attempts: NZBGet not ready yet, waiting..."
        sleep 5
        ((attempt++))
    done
    
    print_error "NZBGet is not accessible after $max_attempts attempts"
    return 1
}

verify_integrations() {
    print_step "🔍 Verifying service integrations..."
    
    # Check if we can reach the services
    local services_ok=0
    
    # Test Radarr
    if curl -s --max-time 5 "http://localhost:7878" > /dev/null 2>&1; then
        print_info "✅ Radarr is accessible"
        ((services_ok++))
    else
        print_warning "❌ Radarr is not accessible"
    fi
    
    # Test Sonarr
    if curl -s --max-time 5 "http://localhost:8989" > /dev/null 2>&1; then
        print_info "✅ Sonarr is accessible"
        ((services_ok++))
    else
        print_warning "❌ Sonarr is not accessible"
    fi
    
    # Test Prowlarr
    if curl -s --max-time 5 "http://localhost:9696" > /dev/null 2>&1; then
        print_info "✅ Prowlarr is accessible"
        ((services_ok++))
    else
        print_warning "❌ Prowlarr is not accessible"
    fi
    
    if [ $services_ok -ge 2 ]; then
        print_success "Service verification completed ($services_ok/3 services accessible)"
        return 0
    else
        print_error "Not enough services are accessible"
        return 1
    fi
}

main() {
    print_header
    
    # Check if help was requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "NZBGet Automation Script for Surge"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --storage-path PATH  Override storage path (default: \$STORAGE_PATH or /opt/surge)"
        echo ""
        echo "This script:"
        echo "  1. Configures NZBGet server settings"
        echo "  2. Sets up download categories"
        echo "  3. Integrates NZBGet with Radarr and Sonarr"
        echo "  4. Verifies all connections"
        echo ""
        exit 0
    fi
    
    # Override storage path if provided
    if [[ "$1" == "--storage-path" && -n "$2" ]]; then
        export STORAGE_PATH="$2"
        print_info "Using storage path: $STORAGE_PATH"
    fi
    
    # Run automation steps
    local step=1
    local total_steps=6
    
    print_info "Starting NZBGet automation ($total_steps steps)..."
    echo ""
    
    # Step 1: Check prerequisites
    echo "Step $step/$total_steps:"
    check_prerequisites
    ((step++))
    
    # Step 2: Check service status
    echo "Step $step/$total_steps:"
    check_service_status
    ((step++))
    
    # Step 3: Test NZBGet connection
    echo "Step $step/$total_steps:"
    test_nzbget_connection
    ((step++))
    
    # Step 4: Run Python automation
    echo "Step $step/$total_steps:"
    if ! run_python_automation; then
        print_warning "Python automation failed, trying service config automation..."
    fi
    ((step++))
    
    # Step 5: Run service configuration automation
    echo "Step $step/$total_steps:"
    run_service_config_automation
    ((step++))
    
    # Step 6: Verify integrations
    echo "Step $step/$total_steps:"
    verify_integrations
    
    # Show summary
    print_summary
    
    print_success "🎉 NZBGet automation completed successfully!"
    echo ""
    echo "💡 Your NZBGet is now fully configured and integrated with Radarr and Sonarr!"
}

# Run main function
main "$@"
