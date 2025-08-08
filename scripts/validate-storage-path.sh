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
if [[ "$PROJECT_ABS" == "$STORAGE_ABS" ]]; then
    echo "❌ CRITICAL ERROR: STORAGE_PATH is set to the project directory!"
    echo "   This will cause service data to be stored in your Git repository."
    echo ""
    echo "🔧 To fix this, update your .env file:"
    echo "   Current: STORAGE_PATH=$STORAGE_PATH"
    echo "   Suggested: STORAGE_PATH=${DATA_ROOT:-/opt/surge}"
    echo ""
    echo "   Then run: ./surge deploy <service>"
    exit 1
fi

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

FOUND_SERVICES=()
for dir in "${SERVICE_DIRS[@]}"; do
    if [[ -d "$PROJECT_DIR/$dir" ]]; then
        FOUND_SERVICES+=("$dir")
    fi
done

if [[ ${#FOUND_SERVICES[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  WARNING: Found service directories in project folder:"
    for dir in "${FOUND_SERVICES[@]}"; do
        echo "   - $dir/"
    done
    echo ""
    echo "🔧 These should be moved to your storage location:"
    echo "   for dir in ${FOUND_SERVICES[*]}; do"
    echo "     [[ -d \"\$dir\" ]] && mv \"\$dir\" \"$STORAGE_PATH/\""
    echo "   done"
    echo ""
    echo "   Or removed if they're duplicates:"
    echo "   rm -rf ${FOUND_SERVICES[*]}"
    exit 1
fi

echo "✅ No service directories found in project folder"
echo "🎉 Storage path validation passed!"
