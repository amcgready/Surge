#!/bin/bash

# Surge Deployment Fix Validation Script
# This script validates that all the recent fixes are working properly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔧 Surge Deployment Fix Validation"
echo "=================================="
echo

# Check if .env file exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "❌ .env file not found. Please run first-time-setup.sh first."
    exit 1
fi

# Load environment variables
echo "📋 Loading environment variables from .env..."
source "$PROJECT_ROOT/.env" 2>/dev/null || true

# Check critical variables
echo "🔍 Checking critical environment variables..."
echo "   STORAGE_PATH: ${STORAGE_PATH:-NOT SET}"
echo "   RD_API_TOKEN: ${RD_API_TOKEN:0:8}${RD_API_TOKEN:+...}"
echo "   MEDIA_SERVER: ${MEDIA_SERVER:-NOT SET}"

# Validate storage path permissions
echo
echo "📁 Validating storage path permissions..."
STORAGE_PATH=${STORAGE_PATH:-/opt/surge}

if [ -d "$STORAGE_PATH" ]; then
    echo "✅ Storage path exists: $STORAGE_PATH"
    
    # Check if we can write to it
    if [ -w "$STORAGE_PATH" ]; then
        echo "✅ Storage path is writable"
    else
        echo "⚠️ Storage path may need permission fixes"
        echo "   Run: sudo chown -R $(id -u):$(id -g) $STORAGE_PATH"
    fi
    
    # Check for service directories
    local service_dirs=("Radarr" "Sonarr" "Prowlarr" "Bazarr" "Plex")
    for service in "${service_dirs[@]}"; do
        if [ -d "$STORAGE_PATH/$service" ]; then
            echo "✅ $service directory exists"
        else
            echo "ℹ️ $service directory will be created on deploy"
        fi
    done
else
    echo "ℹ️ Storage path will be created on deploy: $STORAGE_PATH"
fi

# Check script permissions
echo
echo "🔧 Checking script permissions..."
local scripts=("deploy.sh" "post-deploy-config.sh" "first-time-setup.sh" "api-key-utils.sh")
for script in "${scripts[@]}"; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        if [ -x "$SCRIPT_DIR/$script" ]; then
            echo "✅ $script is executable"
        else
            echo "⚠️ Making $script executable..."
            chmod +x "$SCRIPT_DIR/$script"
        fi
    else
        echo "❌ Missing required script: $script"
    fi
done

# Check Python dependencies
echo
echo "🐍 Checking Python availability..."
if command -v python3 &> /dev/null; then
    echo "✅ Python3 is available"
    echo "   Version: $(python3 --version)"
else
    echo "❌ Python3 not found - some automation features will not work"
    echo "   Install with: sudo apt-get install python3"
fi

# Check Docker
echo
echo "🐳 Checking Docker status..."
if command -v docker &> /dev/null; then
    echo "✅ Docker is available"
    if docker ps &> /dev/null; then
        echo "✅ Docker is running"
    else
        echo "❌ Docker is not running or requires privileges"
        echo "   Try: sudo systemctl start docker"
    fi
else
    echo "❌ Docker not found"
    echo "   Install Docker first: https://docs.docker.com/install/"
fi

# Check docker-compose
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1; then
    echo "✅ Docker Compose is available"
else
    echo "❌ Docker Compose not found"
fi

# Validate key configuration files
echo
echo "📄 Checking configuration files..."
if [ -f "$PROJECT_ROOT/docker-compose.yml" ]; then
    echo "✅ Main docker-compose.yml exists"
else
    echo "❌ Main docker-compose.yml missing"
fi

if [ -f "$PROJECT_ROOT/docker-compose.plex.yml" ]; then
    echo "✅ Plex docker-compose file exists"
else
    echo "❌ Plex docker-compose file missing"
fi

# Summary
echo
echo "📊 Validation Summary"
echo "===================="

if [ -f "$PROJECT_ROOT/.env" ] && [ -n "$MEDIA_SERVER" ]; then
    echo "✅ Basic configuration looks good"
    echo
    echo "🚀 Ready to deploy! Run:"
    echo "   ./surge deploy ${MEDIA_SERVER:-plex}"
    echo
    echo "📝 After deployment, check logs with:"
    echo "   tail -f logs/post-deploy.log"
else
    echo "⚠️ Configuration needs attention"
    echo
    echo "🔧 Next steps:"
    echo "   1. Run: ./surge setup"
    echo "   2. Then run: ./surge deploy plex"
fi

echo
echo "🔍 For troubleshooting, check:"
echo "   - logs/post-deploy.log (after deployment)"
echo "   - Docker logs: docker compose logs -f"
echo "   - Service status: docker compose ps"
