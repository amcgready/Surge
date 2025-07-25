#!/bin/bash

# ===========================================
# SURGE TEST DEPLOYMENT
# ===========================================

echo "Testing Surge deployment..."

# Set up test environment
cp .env.example .env

# Update paths for test
sed -i "s|DATA_ROOT=/opt/surge|DATA_ROOT=$(pwd)/test-data|g" .env
sed -i "s|PUID=1000|PUID=$(id -u)|g" .env
sed -i "s|PGID=1000|PGID=$(id -g)|g" .env

echo "✅ Environment configured for testing"

# Create test directories
mkdir -p test-data/{media/{movies,tv,music},downloads,config,logs}
echo "✅ Test directories created"

echo ""
echo "🚀 Ready to test Surge!"
echo ""
echo "Try these commands:"
echo "  ./surge deploy plex     # Deploy with Plex"
echo "  ./surge status          # Check service status"
echo "  ./surge logs            # View all logs"
echo "  ./surge stop            # Stop all services"
echo ""
echo "Access services at:"
echo "  Homepage: http://localhost:3000"
echo "  Plex: http://localhost:32400/web"
echo "  Radarr: http://localhost:7878"
echo "  Sonarr: http://localhost:8989"
