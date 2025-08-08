#!/bin/bash

# CineSync Configuration Generator Script
# This script generates the proper env file for CineSync container
# using the values from the main Surge .env file

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_FILE="$PROJECT_DIR/configs/cinesync-env.template"


# Read STORAGE_PATH from .env file (required)
if [ -f "$PROJECT_DIR/.env" ]; then
    STORAGE_PATH=$(grep "^STORAGE_PATH=" "$PROJECT_DIR/.env" | head -1 | cut -d'=' -f2 | tr -d '\n\r')
fi
if [ -z "$STORAGE_PATH" ]; then
    print_error "STORAGE_PATH is not set in $PROJECT_DIR/.env. Please set STORAGE_PATH before running this script."
    exit 1
fi


OUTPUT_DIR="$STORAGE_PATH/Cinesync/config"
OUTPUT_FILE="$OUTPUT_DIR/.env"

print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Check if main .env file exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    print_error "Main .env file not found at $PROJECT_DIR/.env"
    print_info "Please run the setup script first to create your .env file"
    exit 1
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    print_error "CineSync template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Source the main environment file
print_info "Loading environment variables from main .env file..."
set -a
source "$PROJECT_DIR/.env"
set +a

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate the CineSync environment file
print_info "Generating CineSync environment file..."

# Use envsubst to substitute variables in the template
if command -v envsubst >/dev/null 2>&1; then
    envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
else
    # Fallback: manual substitution for common variables
    print_warning "envsubst not found, using basic substitution"
    cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
    
    # Replace common variables manually
    sed -i "s|\${CINESYNC_SOURCE_DIR}|${CINESYNC_SOURCE_DIR:-${DATA_ROOT}/downloads}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_DESTINATION_DIR}|${CINESYNC_DESTINATION_DIR:-${DATA_ROOT}/media}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_USE_SOURCE_STRUCTURE}|${CINESYNC_USE_SOURCE_STRUCTURE:-false}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_LAYOUT}|${CINESYNC_LAYOUT:-true}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_ANIME_SEPARATION}|${CINESYNC_ANIME_SEPARATION:-true}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_4K_SEPARATION}|${CINESYNC_4K_SEPARATION:-true}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_KIDS_SEPARATION}|${CINESYNC_KIDS_SEPARATION:-false}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_TMDB_API_KEY}|${CINESYNC_TMDB_API_KEY:-${TMDB_API_KEY}}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_LOG_LEVEL}|${CINESYNC_LOG_LEVEL:-INFO}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_IP}|${CINESYNC_IP:-0.0.0.0}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_API_PORT}|${CINESYNC_API_PORT:-8082}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_UI_PORT}|${CINESYNC_UI_PORT:-5173}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_USERNAME}|${CINESYNC_USERNAME:-admin}|g" "$OUTPUT_FILE"
    sed -i "s|\${CINESYNC_PASSWORD}|${CINESYNC_PASSWORD:-admin}|g" "$OUTPUT_FILE"
fi

# Set proper permissions
chmod 600 "$OUTPUT_FILE"

print_success "CineSync environment file generated successfully!"
print_info "Location: $OUTPUT_FILE"
print_info ""
print_info "CineSync will now use this configuration file when the container starts."
print_info "You can customize the settings by editing either:"
print_info "  1. Main .env file (recommended for most settings)"
print_info "  2. $OUTPUT_FILE (for CineSync-specific advanced settings)"
print_info ""
print_warning "Note: If you modify the main .env file, re-run this script to regenerate the CineSync config."
