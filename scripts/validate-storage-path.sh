#!/bin/bash

# Validate Storage Path Configuration
# Ensures STORAGE_PATH is not set to the project directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

echo "🔍 Validating storage path configuration..."

# Source environment file
if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

# Check if STORAGE_PATH is set
if [[ -z "${STORAGE_PATH:-}" ]]; then
    echo "❌ STORAGE_PATH is not set in .env file"
    exit 1
fi

# Resolve absolute paths for comparison
PROJECT_ABS=$(realpath "$PROJECT_DIR")
STORAGE_ABS=$(realpath "$STORAGE_PATH")

echo "📁 Project directory: $PROJECT_ABS"
echo "💾 Storage path: $STORAGE_ABS"

# Check if STORAGE_PATH is the same as project directory

# Check if STORAGE_PATH is inside project directory
if [[ "$STORAGE_ABS" == "$PROJECT_ABS"/* ]]; then
    echo "⚠️  WARNING: STORAGE_PATH is inside the project directory!"
    echo "   This may cause service data to be included in Git repository."
    echo "   Consider using a path outside the project directory."
fi

# Check if storage directory exists and is writable
if [[ ! -d "$STORAGE_PATH" ]]; then
    echo "📁 Storage directory does not exist, will be created: $STORAGE_PATH"
elif [[ ! -w "$STORAGE_PATH" ]]; then
    echo "❌ Storage directory is not writable: $STORAGE_PATH"
    exit 1
fi

echo "✅ Storage path configuration is valid"

# Check for service directories in project folder
SERVICE_DIRS=(
    "Bazarr" "Plex" "Radarr" "Sonarr" "Prowlarr" "RDT-Client" 
    "Overseerr" "Tautulli" "Homepage" "GAPS" "Posterizarr" 
    "Placeholdarr" "NZBGet" "Cinesync" "media" "downloads"
)


echo "✅ No service directories found in project folder"
echo "🎉 Storage path validation passed!"
