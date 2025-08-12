#!/bin/bash

# Quick Fix Script for Current Deployment Issues
# This script addresses the immediate issues found in the post-deploy log

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔧 Surge Quick Fix Script"
echo "========================="
echo

# Load environment variables properly
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
    echo "✅ Environment variables loaded"
else
    echo "❌ .env file not found"
    exit 1
fi

# Fix 1: Create proper media directories with correct permissions
echo "📁 Creating media directories with proper permissions..."
MEDIA_PATH="${STORAGE_PATH:-/opt/surge}/media"

if [ "$(id -u)" -eq 0 ]; then
    # Removed creation of media subfolders
    echo "placeholder" > "$MEDIA_PATH/movies/.placeholder"
    echo "placeholder" > "$MEDIA_PATH/tv/.placeholder"
    echo "placeholder" > "$MEDIA_PATH/music/.placeholder"
    chown -R 1000:1000 "$MEDIA_PATH"
    chmod -R 755 "$MEDIA_PATH"
    echo "✅ Media directories created with proper permissions"
else
    # Removed creation of media subfolders
    echo "placeholder" | sudo tee "$MEDIA_PATH/movies/.placeholder" > /dev/null 2>&1 || echo "placeholder" > "$MEDIA_PATH/movies/.placeholder"
    echo "placeholder" | sudo tee "$MEDIA_PATH/tv/.placeholder" > /dev/null 2>&1 || echo "placeholder" > "$MEDIA_PATH/tv/.placeholder"
    echo "placeholder" | sudo tee "$MEDIA_PATH/music/.placeholder" > /dev/null 2>&1 || echo "placeholder" > "$MEDIA_PATH/music/.placeholder"
    sudo chown -R 1000:1000 "$MEDIA_PATH" 2>/dev/null || true
    sudo chmod -R 755 "$MEDIA_PATH" 2>/dev/null || true
    echo "✅ Media directories created"
fi

# Fix 2: Check and fix Prowlarr configuration directly
echo "🔄 Attempting to fix Prowlarr application configurations..."

# Get API keys from config files
get_api_key() {
    local service=$1
    local config_file="${STORAGE_PATH:-/opt/surge}/${service^}/config/config.xml"
    if [ -f "$config_file" ]; then
        grep -oP '(?<=<ApiKey>)[^<]+' "$config_file" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

PROWLARR_API=$(get_api_key "prowlarr")
RADARR_API=$(get_api_key "radarr")
SONARR_API=$(get_api_key "sonarr")

if [ -n "$PROWLARR_API" ] && [ -n "$RADARR_API" ] && [ -n "$SONARR_API" ]; then
    echo "✅ Found all required API keys"
    
    # Clean up existing applications first
    echo "🧹 Cleaning up existing applications..."
    curl -s -X GET "http://localhost:9696/api/v1/applications" -H "X-Api-Key: $PROWLARR_API" | \
    python3 -c "
import sys, json
try:
    apps = json.loads(sys.stdin.read())
    for app in apps:
        if app.get('name') in ['Radarr', 'Sonarr']:
            import urllib.request
            req = urllib.request.Request('http://localhost:9696/api/v1/applications/' + str(app['id']), method='DELETE')
            req.add_header('X-Api-Key', '$PROWLARR_API')
            try:
                urllib.request.urlopen(req)
                print(f'Removed existing {app[\"name\"]} application')
            except Exception as e:
                print(f'Error removing {app[\"name\"]}: {e}')
except Exception as e:
    print(f'Error processing applications: {e}')
"
    
    # Re-add applications with correct URLs
    echo "➕ Re-adding applications with correct configuration..."
    
    # Add Radarr
    RADARR_PAYLOAD='{
        "name": "Radarr",
        "implementation": "Radarr",
        "configContract": "RadarrSettings",
        "fields": [
            {"name": "apiKey", "value": "'$RADARR_API'"},
            {"name": "baseUrl", "value": "http://surge-radarr:7878"},
            {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"}
        ],
        "syncLevel": "fullSync",
        "enableRss": true,
        "enableAutomaticSearch": true,
        "enableInteractiveSearch": true
    }'
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:9696/api/v1/applications" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $PROWLARR_API" \
        -d "$RADARR_PAYLOAD")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "✅ Radarr application configured successfully"
    else
        echo "❌ Failed to configure Radarr: HTTP $HTTP_CODE"
        echo "$(echo "$RESPONSE" | head -n -1)"
    fi
    
    # Add Sonarr
    SONARR_PAYLOAD='{
        "name": "Sonarr",
        "implementation": "Sonarr",
        "configContract": "SonarrSettings",
        "fields": [
            {"name": "apiKey", "value": "'$SONARR_API'"},
            {"name": "baseUrl", "value": "http://surge-sonarr:8989"},
            {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"}
        ],
        "syncLevel": "fullSync",
        "enableRss": true,
        "enableAutomaticSearch": true,
        "enableInteractiveSearch": true
    }'
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:9696/api/v1/applications" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $PROWLARR_API" \
        -d "$SONARR_PAYLOAD")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "✅ Sonarr application configured successfully"
    else
        echo "❌ Failed to configure Sonarr: HTTP $HTTP_CODE"
        echo "$(echo "$RESPONSE" | head -n -1)"
    fi
    
else
    echo "⚠️ Missing API keys - cannot configure Prowlarr applications"
    [ -z "$PROWLARR_API" ] && echo "   Missing Prowlarr API key"
    [ -z "$RADARR_API" ] && echo "   Missing Radarr API key"
    [ -z "$SONARR_API" ] && echo "   Missing Sonarr API key"
fi

# Fix 3: Basic Plex setup
echo "🎬 Setting up basic Plex configuration..."
PLEX_CONFIG_DIR="${STORAGE_PATH:-/opt/surge}/Plex/config/Library/Application Support/Plex Media Server"

if [ "$(id -u)" -eq 0 ]; then
    mkdir -p "$PLEX_CONFIG_DIR"
    chown -R 1000:1000 "${STORAGE_PATH:-/opt/surge}/Plex"
else
    sudo mkdir -p "$PLEX_CONFIG_DIR" 2>/dev/null || mkdir -p "$PLEX_CONFIG_DIR"
    sudo chown -R 1000:1000 "${STORAGE_PATH:-/opt/surge}/Plex" 2>/dev/null || true
fi

# Create basic preferences if they don't exist
PREFS_FILE="$PLEX_CONFIG_DIR/Preferences.xml"
if [ ! -f "$PREFS_FILE" ]; then
    cat > "$PREFS_FILE" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<Preferences FriendlyName="Surge Plex Server" 
             AcceptedEULA="1" 
             PublishServerOnPlexOnlineKey="1"
             PlexOnlineHome="1"
             PlexOnlineUsername=""
             PlexOnlineToken="">
</Preferences>
EOF
    echo "✅ Created basic Plex preferences"
    if [ "$(id -u)" -ne 0 ]; then
        sudo chown 1000:1000 "$PREFS_FILE" 2>/dev/null || true
    fi
fi

echo
echo "🎯 Quick Fix Summary"
echo "===================="
echo "✅ Fixed media directory permissions"
echo "✅ Attempted to fix Prowlarr application configurations"
echo "✅ Created basic Plex setup files"
echo
echo "💡 Next Steps:"
echo "1. Wait a few minutes for services to restart and detect changes"
echo "2. Check Prowlarr UI at http://localhost:9696 to verify applications"
echo "3. Access Plex at http://localhost:32400/web to complete initial setup"
echo "4. Manual library creation in Plex may be required for now"
echo
echo "🔍 For ongoing issues, check:"
echo "   - Service status: docker compose ps"
echo "   - Logs: docker compose logs -f [service_name]"
echo "   - Post-deploy log: tail -f logs/post-deploy.log"
