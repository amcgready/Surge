#!/bin/bash

# Post-deployment configuration script
# Runs after services are fully started to configure connections

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/shared-config.sh"
source "$SCRIPT_DIR/api-key-utils.sh"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a  # automatically export all variables
    source "$PROJECT_ROOT/.env"
    set +a  # turn off auto-export
fi

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
    
    # Clean up existing applications first to avoid "Should be unique" errors
    log_info "Cleaning up existing applications to avoid duplicates..."
    local existing_apps=$(curl -s -H "X-Api-Key: $prowlarr_api" "http://localhost:9696/api/v1/applications")
    if [ $? -eq 0 ] && [ -n "$existing_apps" ]; then
        echo "$existing_apps" | python3 -c "
import sys, json
try:
    apps = json.loads(sys.stdin.read())
    for app in apps:
        if app.get('name') in ['Radarr', 'Sonarr']:
            import urllib.request
            req = urllib.request.Request('http://localhost:9696/api/v1/applications/' + str(app['id']), method='DELETE')
            req.add_header('X-Api-Key', '$prowlarr_api')
            try:
                urllib.request.urlopen(req)
                print(f'Removed existing {app[\"name\"]} application')
            except:
                pass
except:
    pass
"
    fi
    
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
        {"name": "baseUrl", "value": "http://surge-radarr:7878"},
        {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"}
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
        {"name": "baseUrl", "value": "http://surge-sonarr:8989"},
        {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"}
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

# Configure Plex libraries
configure_plex_libraries() {
    log_info "Configuring Plex libraries based on CineSync folder structure..."
    
    # Wait for Plex to be fully ready
    if ! wait_for_service "Plex" 32400; then
        log_error "Plex is not ready, skipping library configuration"
        return 1
    fi
    
    # Additional wait for Plex to be fully initialized
    log_info "Waiting additional 60 seconds for Plex to fully initialize..."
    sleep 60
    
    # Create sample media structure to ensure Plex can find content
    log_info "Creating sample media structure to initialize Plex libraries..."
    local media_base="${STORAGE_PATH:-/opt/surge}/media"
    
    # Create basic directory structure with proper permissions
    if [ "$(id -u)" -eq 0 ]; then
        # Running as root
        # Removed creation of media subfolders
        touch "$media_base/movies/.placeholder"
        touch "$media_base/tv/.placeholder" 
        touch "$media_base/music/.placeholder"
        chown -R 1000:1000 "$media_base"
        chmod -R 755 "$media_base"
    else
        # Not running as root, try without sudo first, then with non-interactive sudo
        # Removed creation of media subfolders
            # Regular user has write access
            touch "$media_base/movies/.placeholder" 2>/dev/null || true
            touch "$media_base/tv/.placeholder" 2>/dev/null || true
            touch "$media_base/music/.placeholder" 2>/dev/null || true
            # Try to set permissions if possible
            chown -R 1000:1000 "$media_base" 2>/dev/null || true
            chmod -R 755 "$media_base" 2>/dev/null || true
        else
            # Need elevated permissions, but avoid interactive sudo
            log_info "Creating media directories with elevated permissions..."
            # Create directories without sudo first if possible
            # Removed creation of media subfolders
                log_error "Cannot create media directories. Please ensure proper permissions on $media_base"
                return 0  # Don't fail the entire deployment for this
            }
        fi
    fi
    
    # Check if the Plex library configuration script exists
    if [ ! -f "$SCRIPT_DIR/configure-plex-libraries.py" ]; then
        log_error "Plex library configuration script not found"
        return 1
    fi
    
    # Set environment variables for the script to read CineSync config
    # Read all CineSync-related environment variables from .env and docker-compose
    export STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_ROOT/.env" | head -1 | cut -d'=' -f2 | tr -d '\n\r' || echo "/opt/surge")
    
    # CineSync layout and separation settings
    export CINESYNC_LAYOUT=$(grep "^CINESYNC_LAYOUT=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "true")
    export CINESYNC_ANIME_SEPARATION=$(grep "^CINESYNC_ANIME_SEPARATION=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "true")
    export CINESYNC_4K_SEPARATION=$(grep "^CINESYNC_4K_SEPARATION=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "false")
    export CINESYNC_KIDS_SEPARATION=$(grep "^CINESYNC_KIDS_SEPARATION=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "false")
    
    # CineSync custom folder names (read from .env or use docker-compose defaults)
    export CINESYNC_CUSTOM_MOVIE_FOLDER=$(grep "^CINESYNC_CUSTOM_MOVIE_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "Movies")
    export CINESYNC_CUSTOM_SHOW_FOLDER=$(grep "^CINESYNC_CUSTOM_SHOW_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "TV Series")
    export CINESYNC_CUSTOM_4KMOVIE_FOLDER=$(grep "^CINESYNC_CUSTOM_4KMOVIE_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "4K Movies")
    export CINESYNC_CUSTOM_4KSHOW_FOLDER=$(grep "^CINESYNC_CUSTOM_4KSHOW_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "4K Series")
    export CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER=$(grep "^CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "Anime Movies")
    export CINESYNC_CUSTOM_ANIME_SHOW_FOLDER=$(grep "^CINESYNC_CUSTOM_ANIME_SHOW_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "Anime Series")
    export CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=$(grep "^CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "Kids Movies")
    export CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=$(grep "^CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=" "$PROJECT_ROOT/.env" | cut -d'=' -f2 | tr -d '\n\r' 2>/dev/null || echo "Kids Series")
    
    # Run the Plex library configuration script
    log_info "Running Plex library configuration script..."
    if python3 "$SCRIPT_DIR/configure-plex-libraries.py" --plex-url "http://localhost:32400" --storage-path "$STORAGE_PATH"; then
        log_info "✅ Plex libraries configured successfully"
        
        # Now that libraries are created, we can get the Plex token
        log_info "Attempting to retrieve Plex token for other integrations..."
        local plex_token_file="${STORAGE_PATH}/Plex/config/Library/Application Support/Plex Media Server/Preferences.xml"
        if [ -f "$plex_token_file" ]; then
            local plex_token=$(grep -oP 'PlexOnlineToken="[^"]*"' "$plex_token_file" | cut -d'"' -f2 2>/dev/null || echo "")
            if [ -n "$plex_token" ]; then
                log_info "✅ Plex token retrieved successfully for other service integrations"
                export PLEX_TOKEN="$plex_token"
            fi
        fi
    else
        log_error "❌ Failed to configure Plex libraries"
        return 1
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
    
    # Configure Plex libraries (if Plex is running)
    if docker ps --format "table {{.Names}}" | grep -q "plex"; then
        configure_plex_libraries
    fi
    
    # Run comprehensive interconnection configuration
    if [ -f "$SCRIPT_DIR/configure-interconnections.py" ]; then
        log_info "Running comprehensive service interconnection configuration..."
        if python3 "$SCRIPT_DIR/configure-interconnections.py" "$STORAGE_PATH"; then
            log_info "✅ All service interconnections configured successfully"
        else
            log_error "❌ Service interconnection configuration failed"
        fi
    fi
    
    
    # Configure Kometa (if Kometa is running)
    if docker ps --format "table {{.Names}}" | grep -q "kometa"; then
        if [ -f "$SCRIPT_DIR/configure-kometa.py" ]; then
            log_info "Configuring Kometa connection to Plex..."
            if python3 "$SCRIPT_DIR/configure-kometa.py" "$STORAGE_PATH"; then
                log_info "✅ Kometa configuration completed successfully"
            else
                log_error "❌ Kometa configuration failed"
            fi
        fi
    fi
    
    # Configure Torrentio indexer (if Prowlarr is running)
    if docker ps --format "table {{.Names}}" | grep -q "prowlarr"; then
        log_info "Configuring Torrentio indexer in Prowlarr..."
        if [ -f "$SCRIPT_DIR/configure-torrentio.py" ]; then
            if python3 "$SCRIPT_DIR/configure-torrentio.py" "$STORAGE_PATH"; then
                log_info "✅ Torrentio indexer configuration completed successfully"
            else
                log_error "❌ Torrentio indexer configuration failed"
            fi
        fi
    fi
    
    # Configure CLI-Debrid automation (if CLI-Debrid is running)
    if docker ps --format "table {{.Names}}" | grep -q "cli-debrid"; then
        log_info "Configuring CLI-Debrid automation..."
        if [ -f "$SCRIPT_DIR/configure-cli-debrid.py" ]; then
            if python3 "$SCRIPT_DIR/configure-cli-debrid.py" "$STORAGE_PATH"; then
                log_info "✅ CLI-Debrid configuration completed successfully"
            else
                log_error "❌ CLI-Debrid configuration failed"
            fi
        else
            log_info "⚠️ CLI-Debrid detected but automation script not found"
        fi
    fi
    
    # Run full auto-configuration
    if [ -f "$SCRIPT_DIR/auto-config.sh" ]; then
        log_info "Running full auto-configuration..."
        "$SCRIPT_DIR/auto-config.sh" --storage-path "$STORAGE_PATH"
    fi
    
    log_info "Post-deployment configuration completed!"
}

# Run main function
main "$@"
