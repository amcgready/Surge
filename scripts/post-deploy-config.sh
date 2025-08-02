#!/bin/bash

# Post-deployment configuration script
# Runs after services are fully started to configure connections

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/shared-config.sh"
source "$SCRIPT_DIR/api-key-utils.sh"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Wait for services to be fully ready
wait_for_service() {
    local service=$1
    local port=$2
    local max_attempts=30
    local attempt=1
    
    log_info "Waiting for $service to be ready on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:$port" > /dev/null 2>&1; then
            log_info "$service is ready!"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: $service not ready yet, waiting..."
        sleep 10
        ((attempt++))
    done
    
    log_error "$service failed to become ready after $max_attempts attempts"
    return 1
}

# Configure Prowlarr applications
configure_prowlarr_apps() {
    log_info "Configuring Prowlarr applications..."
    
    # Get real API keys
    local prowlarr_api=$(get_prowlarr_api_key)
    local radarr_api=$(get_arr_api_key "radarr")
    local sonarr_api=$(get_arr_api_key "sonarr")
    
    if [ -z "$prowlarr_api" ]; then
        log_error "Could not get Prowlarr API key"
        return 1
    fi
    
    log_info "Found Prowlarr API key: ${prowlarr_api:0:8}..."
    
    # Configure Radarr application
    if [ -n "$radarr_api" ]; then
        log_info "Configuring Radarr application in Prowlarr..."
        
        local payload=$(cat <<EOF
{
    "name": "Radarr",
    "implementation": "Radarr",
    "configContract": "RadarrSettings",
    "fields": [
        {"name": "apiKey", "value": "$radarr_api"},
        {"name": "baseUrl", "value": "http://radarr:7878"}
    ],
    "syncLevel": "fullSync",
    "enableRss": true,
    "enableAutomaticSearch": true,
    "enableInteractiveSearch": true,
    "isDefault": true
}
EOF
        )
        
        local response=$(curl -s -w "\n%{http_code}" \
            -H "X-Api-Key: $prowlarr_api" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "http://localhost:9696/api/v1/applications")
        
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | head -n -1)
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
            log_info "✅ Radarr application configured successfully"
        else
            log_error "❌ Failed to configure Radarr application (HTTP $http_code): $body"
        fi
    else
        log_info "Radarr API key not found, skipping configuration"
    fi
    
    # Configure Sonarr application
    if [ -n "$sonarr_api" ]; then
        log_info "Configuring Sonarr application in Prowlarr..."
        
        local payload=$(cat <<EOF
{
    "name": "Sonarr",
    "implementation": "Sonarr",
    "configContract": "SonarrSettings",
    "fields": [
        {"name": "apiKey", "value": "$sonarr_api"},
        {"name": "baseUrl", "value": "http://sonarr:8989"}
    ],
    "syncLevel": "fullSync",
    "enableRss": true,
    "enableAutomaticSearch": true,
    "enableInteractiveSearch": true,
    "isDefault": true
}
EOF
        )
        
        local response=$(curl -s -w "\n%{http_code}" \
            -H "X-Api-Key: $prowlarr_api" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "http://localhost:9696/api/v1/applications")
        
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | head -n -1)
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
            log_info "✅ Sonarr application configured successfully"
        else
            log_error "❌ Failed to configure Sonarr application (HTTP $http_code): $body"
        fi
    else
        log_info "Sonarr API key not found, skipping configuration"
    fi
}

# Main execution
main() {
    log_info "Starting post-deployment configuration..."
    
    # Wait for services to be ready
    if docker ps --format "table {{.Names}}" | grep -q "prowlarr"; then
        wait_for_service "Prowlarr" 9696
    fi
    
    if docker ps --format "table {{.Names}}" | grep -q "radarr"; then
        wait_for_service "Radarr" 7878
    fi
    
    if docker ps --format "table {{.Names}}" | grep -q "sonarr"; then
        wait_for_service "Sonarr" 8989
    fi
    
    # Additional wait for API key generation
    log_info "Waiting additional 30 seconds for API key generation..."
    sleep 30
    
    # Configure applications
    if docker ps --format "table {{.Names}}" | grep -q "prowlarr"; then
        configure_prowlarr_apps
    fi
    
    # Run full auto-configuration
    if [ -f "$SCRIPT_DIR/auto-config.sh" ]; then
        log_info "Running full auto-configuration..."
        "$SCRIPT_DIR/auto-config.sh" --quiet
    fi
    
    log_info "Post-deployment configuration completed!"
}

# Run main function
main "$@"
