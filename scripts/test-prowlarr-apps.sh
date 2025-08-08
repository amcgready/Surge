#!/bin/bash

# Test Prowlarr Applications Configuration
# Verifies that Radarr and Sonarr applications are properly configured in Prowlarr

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
if [[ -f "$PROJECT_DIR/.env" ]]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

# Load API key utilities
source "$SCRIPT_DIR/api-key-utils.sh"

echo "🧪 Testing Prowlarr Application Configuration"
echo "============================================="

# Get Prowlarr API key
PROWLARR_API=$(get_prowlarr_api_key)

if [[ -z "$PROWLARR_API" ]]; then
    echo "❌ Could not get Prowlarr API key"
    exit 1
fi

echo "✅ Found Prowlarr API key: ${PROWLARR_API:0:8}..."

# Test Prowlarr connectivity
if ! curl -s -f -H "X-Api-Key: $PROWLARR_API" "http://localhost:9696/api/v1/health" >/dev/null; then
    echo "❌ Prowlarr is not responding"
    exit 1
fi

echo "✅ Prowlarr is responding"

# Get applications
APPLICATIONS=$(curl -s -H "X-Api-Key: $PROWLARR_API" "http://localhost:9696/api/v1/applications")

if [[ -z "$APPLICATIONS" ]]; then
    echo "❌ Could not retrieve applications from Prowlarr"
    exit 1
fi

echo "📋 Configured Applications:"
echo "$APPLICATIONS" | python3 -c "
import sys, json
try:
    apps = json.loads(sys.stdin.read())
    if not apps:
        print('❌ No applications configured')
        sys.exit(1)
    
    for app in apps:
        name = app.get('name', 'Unknown')
        impl = app.get('implementation', 'Unknown')
        fields = app.get('fields', [])
        
        # Extract key configuration values
        api_key = next((f['value'] for f in fields if f['name'] == 'apiKey'), 'Not found')[:8]
        base_url = next((f['value'] for f in fields if f['name'] == 'baseUrl'), 'Not found')
        prowlarr_url = next((f['value'] for f in fields if f['name'] == 'prowlarrUrl'), 'Not found')
        
        print(f'✅ {name} ({impl}):')
        print(f'   - Base URL: {base_url}')
        print(f'   - Prowlarr URL: {prowlarr_url}')
        print(f'   - API Key: {api_key}...')
        print()
        
        # Validate required fields
        if prowlarr_url == 'Not found':
            print(f'⚠️  WARNING: {name} missing prowlarrUrl field')
        elif prowlarr_url != 'http://surge-prowlarr:9696':
            print(f'⚠️  WARNING: {name} has incorrect prowlarrUrl: {prowlarr_url}')
            
        if base_url == 'Not found':
            print(f'❌ ERROR: {name} missing baseUrl field')
        elif name == 'Radarr' and base_url != 'http://surge-radarr:7878':
            print(f'❌ ERROR: Radarr has incorrect baseUrl: {base_url}')
        elif name == 'Sonarr' and base_url != 'http://surge-sonarr:8989':
            print(f'❌ ERROR: Sonarr has incorrect baseUrl: {base_url}')
            
except json.JSONDecodeError:
    print('❌ Invalid JSON response from Prowlarr')
    sys.exit(1)
except Exception as e:
    print(f'❌ Error processing applications: {e}')
    sys.exit(1)
"

# Test application connectivity from Prowlarr perspective
echo "🔗 Testing Application Connectivity:"

# Test each application
echo "$APPLICATIONS" | python3 -c "
import sys, json, urllib.request
try:
    apps = json.loads(sys.stdin.read())
    
    for app in apps:
        name = app.get('name', 'Unknown')
        app_id = app.get('id')
        
        if app_id:
            test_url = f'http://localhost:9696/api/v1/applications/{app_id}/test'
            
            try:
                req = urllib.request.Request(test_url, method='POST')
                req.add_header('X-Api-Key', '$PROWLARR_API')
                req.add_header('Content-Type', 'application/json')
                
                response = urllib.request.urlopen(req)
                if response.status == 200:
                    print(f'✅ {name} connectivity test passed')
                else:
                    print(f'⚠️  {name} connectivity test returned status {response.status}')
                    
            except urllib.error.HTTPError as e:
                print(f'❌ {name} connectivity test failed: HTTP {e.code}')
                if e.code == 400:
                    error_body = e.read().decode('utf-8')
                    print(f'   Error details: {error_body}')
            except Exception as e:
                print(f'❌ {name} connectivity test failed: {e}')
        
except Exception as e:
    print(f'❌ Error testing connectivity: {e}')
"

echo ""
echo "🎯 Test Summary:"
echo "- If all tests pass, Prowlarr applications are properly configured"
echo "- If prowlarrUrl warnings appear, run: ./scripts/quick-fix.sh"
echo "- Check Prowlarr UI at http://localhost:9696 for visual confirmation"
