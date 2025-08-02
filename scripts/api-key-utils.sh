#!/bin/bash

# API Key Extraction and Service Auto-Configuration Utilities
# These functions automatically extract API keys from *arr services and 
# configure other services to connect to them

# Extract API key from *arr service config.xml
get_arr_api_key() {
    local service=$1
    local port=$2
    local config_path="${STORAGE_PATH:-/opt/surge}/${service^}/config/config.xml"
    
    # First try to extract from config file
    if [ -f "$config_path" ]; then
        local api_key=$(grep -oP '(?<=<ApiKey>)[^<]+' "$config_path" 2>/dev/null || echo "")
        if [ -n "$api_key" ]; then
            echo "$api_key"
            return 0
        fi
    fi
    
    # If config file doesn't exist or has no API key, try API call
    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s "http://localhost:$port/api/v3/config/host" 2>/dev/null || echo "")
        if [ -n "$response" ]; then
            local api_key=$(echo "$response" | grep -oP '"apiKey":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
            if [ -n "$api_key" ]; then
                echo "$api_key"
                return 0
            fi
        fi
    fi
    
    echo ""
    return 1
}

# Extract Prowlarr API key with retry logic
get_prowlarr_api_key() {
    local config_path="${STORAGE_PATH:-/opt/surge}/Prowlarr/config/config.xml"
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if [ -f "$config_path" ]; then
            local api_key=$(grep -oP '(?<=<ApiKey>)[^<]+' "$config_path" 2>/dev/null || echo "")
            if [ -n "$api_key" ]; then
                echo "$api_key"
                return 0
            fi
        fi
        
        # Try API call if config file method fails
        if command -v curl >/dev/null 2>&1; then
            local response=$(curl -s "http://localhost:9696/api/v1/config/host" 2>/dev/null || echo "")
            if [ -n "$response" ]; then
                local api_key=$(echo "$response" | grep -oP '"apiKey":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
                if [ -n "$api_key" ]; then
                    echo "$api_key"
                    return 0
                fi
            fi
        fi
        
        [ $attempt -lt $max_attempts ] && sleep 2
        ((attempt++))
    done
    
    echo ""
    return 1
}

# Get service connection details (URL and API key)
get_service_details() {
    local service=$1
    local port=""
    local container_name=""
    
    case "$service" in
        "radarr")
            port="7878"
            container_name="surge-radarr"
            ;;
        "sonarr")
            port="8989"
            container_name="surge-sonarr"
            ;;
        "prowlarr")
            port="9696"
            container_name="surge-prowlarr"
            ;;
        "bazarr")
            port="6767"
            container_name="surge-bazarr"
            ;;
        *)
            return 1
            ;;
    esac
    
    local api_key=""
    if [ "$service" = "prowlarr" ]; then
        api_key=$(get_prowlarr_api_key)
    else
        api_key=$(get_arr_api_key "$service" "$port")
    fi
    
    if [ -n "$api_key" ]; then
        # Output in format: URL|API_KEY|PORT|CONTAINER_NAME
        echo "http://localhost:$port|$api_key|$port|$container_name"
        return 0
    else
        return 1
    fi
}

# Auto-configure service connections using discovered API keys
auto_configure_service_connections() {
    local target_service=$1
    
    echo "🔧 Auto-configuring $target_service connections..."
    
    # Get Radarr and Sonarr details
    local radarr_details=$(get_service_details "radarr")
    local sonarr_details=$(get_service_details "sonarr")
    local prowlarr_details=$(get_service_details "prowlarr")
    
    case "$target_service" in
        "bazarr")
            configure_bazarr_connections "$radarr_details" "$sonarr_details"
            ;;
        "overseerr")
            configure_overseerr_connections "$radarr_details" "$sonarr_details"
            ;;
        "gaps")
            configure_gaps_connections "$radarr_details"
            ;;
        "placeholdarr")
            configure_placeholdarr_connections "$radarr_details" "$sonarr_details"
            ;;
        "tautulli")
            configure_tautulli_connections "$radarr_details" "$sonarr_details"
            ;;
        *)
            echo "⚠️ Auto-configuration not implemented for $target_service"
            return 1
            ;;
    esac
}

# Configure Bazarr connections to Radarr and Sonarr
configure_bazarr_connections() {
    local radarr_details=$1
    local sonarr_details=$2
    local config_path="${STORAGE_PATH:-/opt/surge}/Bazarr/config/config.ini"
    
    if [ -n "$radarr_details" ] || [ -n "$sonarr_details" ]; then
        echo "  📺 Configuring Bazarr connections..."
        
        mkdir -p "$(dirname "$config_path")"
        
        # Create or update config.ini
        if [ ! -f "$config_path" ]; then
            cat > "$config_path" << EOF
[general]
debug = False
auto_update = True

EOF
        fi
        
        # Add Radarr section
        if [ -n "$radarr_details" ]; then
            IFS='|' read -r url api_key port container <<< "$radarr_details"
            
            # Remove existing radarr section if it exists
            sed -i '/^\[radarr\]/,/^\[/{ /^\[radarr\]/d; /^\[/!d; }' "$config_path"
            
            cat >> "$config_path" << EOF

[radarr]
enabled = True
url = http://surge-radarr:7878
api_key = $api_key

EOF
        fi
        
        # Add Sonarr section
        if [ -n "$sonarr_details" ]; then
            IFS='|' read -r url api_key port container <<< "$sonarr_details"
            
            # Remove existing sonarr section if it exists
            sed -i '/^\[sonarr\]/,/^\[/{ /^\[sonarr\]/d; /^\[/!d; }' "$config_path"
            
            cat >> "$config_path" << EOF

[sonarr]
enabled = True
url = http://surge-sonarr:8989
api_key = $api_key

EOF
        fi
        
        echo "  ✅ Bazarr connections configured"
    fi
}

# Configure GAPS connection to Radarr
configure_gaps_connections() {
    local radarr_details=$1
    
    if [ -n "$radarr_details" ]; then
        IFS='|' read -r url api_key port container <<< "$radarr_details"
        
        echo "  🧩 Configuring GAPS connection to Radarr..."
        
        # GAPS configuration would go here
        # Note: GAPS typically uses application.properties or similar config file
        local gaps_config="${STORAGE_PATH:-/opt/surge}/GAPS/config/application.properties"
        
        mkdir -p "$(dirname "$gaps_config")"
        
        # Create or update GAPS config
        if [ ! -f "$gaps_config" ]; then
            touch "$gaps_config"
        fi
        
        # Remove existing radarr configuration
        sed -i '/^radarr\./d' "$gaps_config"
        
        cat >> "$gaps_config" << EOF

# Auto-configured Radarr connection
radarr.address=http://surge-radarr:7878
radarr.apiKey=$api_key

EOF
        
        echo "  ✅ GAPS connection to Radarr configured"
    fi
}

# Configure Placeholdarr connections
configure_placeholdarr_connections() {
    local radarr_details=$1
    local sonarr_details=$2
    
    local placeholdarr_config="${STORAGE_PATH:-/opt/surge}/Placeholdarr/config/config.yml"
    
    if [ -n "$radarr_details" ] || [ -n "$sonarr_details" ]; then
        echo "  📄 Configuring Placeholdarr connections..."
        
        mkdir -p "$(dirname "$placeholdarr_config")"
        
        cat > "$placeholdarr_config" << EOF
# Auto-generated Placeholdarr configuration
EOF
        
        if [ -n "$radarr_details" ]; then
            IFS='|' read -r url api_key port container <<< "$radarr_details"
            cat >> "$placeholdarr_config" << EOF

radarr:
  url: http://surge-radarr:7878
  api_key: $api_key
EOF
        fi
        
        if [ -n "$sonarr_details" ]; then
            IFS='|' read -r url api_key port container <<< "$sonarr_details"
            cat >> "$placeholdarr_config" << EOF

sonarr:
  url: http://surge-sonarr:8989
  api_key: $api_key
EOF
        fi
        
        echo "  ✅ Placeholdarr connections configured"
    fi
}

# Configure Tautulli connections (for notifications to *arr services)
configure_tautulli_connections() {
    local radarr_details=$1
    local sonarr_details=$2
    
    if [ -n "$radarr_details" ] || [ -n "$sonarr_details" ]; then
        echo "  📈 Configuring Tautulli webhook connections..."
        
        # Tautulli webhook configuration would typically be done via its web interface
        # or by directly modifying its database, but we can prepare the connection details
        
        local tautulli_config="${STORAGE_PATH:-/opt/surge}/Tautulli/config/config.ini"
        mkdir -p "$(dirname "$tautulli_config")"
        
        if [ ! -f "$tautulli_config" ]; then
            cat > "$tautulli_config" << EOF
[General]
# Auto-generated base configuration

EOF
        fi
        
        # Add connection details as comments for manual configuration
        cat >> "$tautulli_config" << EOF

# Auto-discovered service connections:
EOF
        
        if [ -n "$radarr_details" ]; then
            IFS='|' read -r url api_key port container <<< "$radarr_details"
            cat >> "$tautulli_config" << EOF
# Radarr: http://surge-radarr:7878 (API Key: $api_key)
EOF
        fi
        
        if [ -n "$sonarr_details" ]; then
            IFS='|' read -r url api_key port container <<< "$sonarr_details"
            cat >> "$tautulli_config" << EOF
# Sonarr: http://surge-sonarr:8989 (API Key: $api_key)
EOF
        fi
        
        echo "  ✅ Tautulli connection details prepared"
    fi
}

# Wait for services to be ready and extract all API keys
wait_and_extract_api_keys() {
    echo "🔍 Waiting for services to initialize and extracting API keys..."
    
    local max_wait=300  # 5 minutes
    local wait_time=0
    local check_interval=10
    
    while [ $wait_time -lt $max_wait ]; do
        local radarr_ready=false
        local sonarr_ready=false
        local prowlarr_ready=false
        
        # Check if services are responding
        if curl -s "http://localhost:7878/api/v3/system/status" >/dev/null 2>&1; then
            radarr_ready=true
        fi
        
        if curl -s "http://localhost:8989/api/v3/system/status" >/dev/null 2>&1; then
            sonarr_ready=true
        fi
        
        if curl -s "http://localhost:9696/api/v1/system/status" >/dev/null 2>&1; then
            prowlarr_ready=true
        fi
        
        if $radarr_ready && $sonarr_ready && $prowlarr_ready; then
            echo "  ✅ All services are ready"
            
            # Extract and display API keys
            local radarr_api=$(get_arr_api_key "radarr" "7878")
            local sonarr_api=$(get_arr_api_key "sonarr" "8989")
            local prowlarr_api=$(get_prowlarr_api_key)
            
            echo "  🔑 Extracted API Keys:"
            [ -n "$radarr_api" ] && echo "    📽️  Radarr: $radarr_api"
            [ -n "$sonarr_api" ] && echo "    📺 Sonarr: $sonarr_api"
            [ -n "$prowlarr_api" ] && echo "    🔍 Prowlarr: $prowlarr_api"
            
            return 0
        fi
        
        echo "  ⏳ Waiting for services to be ready... ($wait_time/${max_wait}s)"
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
    done
    
    echo "  ⚠️ Timeout waiting for services to be ready"
    return 1
}

# Main function to auto-configure all service connections
auto_configure_all_connections() {
    echo "🚀 Starting automatic service connection configuration..."
    
    # Wait for services to be ready
    if ! wait_and_extract_api_keys; then
        echo "❌ Failed to extract API keys - services may not be ready"
        return 1
    fi
    
    # Configure connections for each service
    local services=("bazarr" "gaps" "placeholdarr" "tautulli")
    
    for service in "${services[@]}"; do
        # Check if service is enabled/running
        if docker ps --format "table {{.Names}}" | grep -q "surge-$service"; then
            auto_configure_service_connections "$service"
        else
            echo "  ⏭️ Skipping $service (not running)"
        fi
    done
    
    echo "✅ Automatic service connection configuration completed!"
}

# Export functions for use in other scripts
export -f get_arr_api_key
export -f get_prowlarr_api_key
export -f get_service_details
export -f auto_configure_service_connections
export -f wait_and_extract_api_keys
export -f auto_configure_all_connections
