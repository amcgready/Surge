#!/bin/bash

# Test API Key Discovery Fix
# ==========================
# Tests that the interconnection script can now find API keys

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
if [[ -f "$PROJECT_DIR/.env" ]]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

echo "🔍 TESTING API KEY DISCOVERY FIX"
echo "================================="
echo ""

STORAGE_PATH=${STORAGE_PATH:-/opt/surge}
echo "📁 Storage Path: $STORAGE_PATH"
echo ""

echo "🔍 Checking for service configuration files:"
echo "============================================="

# Check each service config file
services=("Radarr" "Sonarr" "Prowlarr" "Bazarr" "Tautulli" "Overseerr")
config_files=(
    "$STORAGE_PATH/Radarr/config/config.xml"
    "$STORAGE_PATH/Sonarr/config/config.xml"
    "$STORAGE_PATH/Prowlarr/config/config.xml"
    "$STORAGE_PATH/Bazarr/config/config/config.yaml"
    "$STORAGE_PATH/Tautulli/config/config.ini"
    "$STORAGE_PATH/Overseerr/config/settings.json"
)

found_configs=0
for i in "${!services[@]}"; do
    service="${services[i]}"
    config_file="${config_files[i]}"
    
    if [[ -f "$config_file" ]]; then
        echo "✅ $service: $config_file"
        found_configs=$((found_configs + 1))
    else
        echo "❌ $service: $config_file (NOT FOUND)"
    fi
done

echo ""
echo "📊 Summary: Found $found_configs/${#services[@]} configuration files"

if [[ $found_configs -gt 0 ]]; then
    echo ""
    echo "🧪 Testing API key extraction:"
    echo "=============================="
    
    # Test with actual API key utilities
    source "$SCRIPT_DIR/api-key-utils.sh"
    
    for service in radarr sonarr prowlarr; do
        api_key=$(get_arr_api_key "$service" 2>/dev/null || echo "")
        if [[ -n "$api_key" ]]; then
            echo "✅ $service API key: ${api_key:0:8}..."
        else
            echo "❌ $service API key: NOT FOUND"
        fi
    done
    
    # Test Prowlarr specifically
    prowlarr_api=$(get_prowlarr_api_key 2>/dev/null || echo "")
    if [[ -n "$prowlarr_api" ]]; then
        echo "✅ Prowlarr API key (specific): ${prowlarr_api:0:8}..."
    else
        echo "❌ Prowlarr API key (specific): NOT FOUND"
    fi
else
    echo ""
    echo "⚠️  No configuration files found. Services may not be deployed yet."
fi

echo ""
echo "🔧 ISSUE DIAGNOSIS:"
echo "=================="
echo "The interconnection script was looking for API keys in:"
echo "  ❌ OLD: \$STORAGE_PATH/config/radarr/config.xml"
echo "  ✅ NEW: \$STORAGE_PATH/Radarr/config/config.xml"
echo ""
echo "This fix aligns with the actual Docker volume mount structure."
echo ""

if [[ $found_configs -gt 0 ]]; then
    echo "🎯 NEXT STEPS:"
    echo "============="
    echo "1. The paths are now fixed in configure-interconnections.py"
    echo "2. Run a test deployment to verify API key discovery works"
    echo "3. Check the post-deploy logs for successful API key discovery"
else
    echo "🎯 NEXT STEPS:"
    echo "============="
    echo "1. Deploy services first: ./surge deploy plex"
    echo "2. Then run this test again to verify API key discovery"
fi
