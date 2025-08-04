#!/bin/bash

# Test script for Plex library automation
# This script demonstrates the library creation functionality

echo "🎬 Testing Plex Library Automation for Surge"
echo "=============================================="

# Configuration
PLEX_URL="http://localhost:32400"
STORAGE_PATH="${STORAGE_PATH:-/opt/surge}"
SERVER_NAME="Surge Media Server"

echo "📋 Configuration:"
echo "  - Plex URL: $PLEX_URL"
echo "  - Storage Path: $STORAGE_PATH"
echo "  - Server Name: $SERVER_NAME"
echo ""

# Test connection first
echo "🔍 Testing Plex connection..."
python3 "$(dirname "$0")/configure-plex-libraries.py" --test-only --plex-url "$PLEX_URL" --storage-path "$STORAGE_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Connection test passed!"
    echo ""
    
    echo "🎯 Creating libraries..."
    python3 "$(dirname "$0")/configure-plex-libraries.py" \
        --plex-url "$PLEX_URL" \
        --storage-path "$STORAGE_PATH" \
        --server-name "$SERVER_NAME"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Library configuration completed successfully!"
        echo ""
        echo "📚 Your Plex server should now have these libraries:"
        echo "  • Movies (/media/movies)"
        echo "  • TV Shows (/media/tv)"
        echo "  • Anime Movies (/media/movies/anime)"
        echo "  • Anime Series (/media/tv/anime)"
        echo ""
        echo "💡 Access your Plex server at: $PLEX_URL/web"
        echo "💡 Libraries may take a few minutes to scan and populate"
    else
        echo "❌ Library configuration failed"
        exit 1
    fi
else
    echo "❌ Connection test failed"
    echo ""
    echo "🔧 Troubleshooting tips:"
    echo "  1. Make sure Plex is running and accessible at $PLEX_URL"
    echo "  2. Check if you have a valid Plex token in your configuration"
    echo "  3. Ensure the storage path ($STORAGE_PATH) exists and is accessible"
    echo "  4. Try running: docker ps | grep plex"
    exit 1
fi
