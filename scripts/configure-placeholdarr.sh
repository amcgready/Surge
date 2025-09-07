#!/bin/bash
# configure-placeholdarr.sh
# This script sets up Placeholdarr and configures Radarr, Sonarr, and Plex to use it.

set -e

# Check STORAGE_PATH
if [ -z "$STORAGE_PATH" ]; then
  echo "STORAGE_PATH is not set. Please export STORAGE_PATH and rerun."
  exit 1
fi

# Clone Placeholdarr repo
cd "$STORAGE_PATH"
if [ ! -d "Placeholdarr" ]; then
  git clone https://github.com/Placeholdarr/Placeholdarr.git
else
  echo "Placeholdarr repo already exists. Skipping clone."
fi

# Create Placeholdarr download folders
mkdir -p "$STORAGE_PATH/Downloads/Placeholdarr/tv"
mkdir -p "$STORAGE_PATH/Downloads/Placeholdarr/movies"

# Set environment variables for Placeholdarr
echo "PLACEHOLDARR_TV_PATH=$STORAGE_PATH/Downloads/Placeholdarr/tv" > "$STORAGE_PATH/Placeholdarr/.env"
echo "PLACEHOLDARR_MOVIES_PATH=$STORAGE_PATH/Downloads/Placeholdarr/movies" >> "$STORAGE_PATH/Placeholdarr/.env"

# Configure Radarr, Sonarr, and Plex
echo "Configuring Radarr, Sonarr, and Plex to use Placeholdarr paths..."
# NOTE: The following are placeholders. Replace with API calls or config edits as needed.
# Radarr
# curl -X PUT ... --data '{"path": "$STORAGE_PATH/Downloads/Placeholdarr/movies"}'
# Sonarr
# curl -X PUT ... --data '{"path": "$STORAGE_PATH/Downloads/Placeholdarr/tv"}'
# Plex
# echo "Add $STORAGE_PATH/Downloads/Placeholdarr to Plex library via Plex UI or API."

echo "Placeholdarr and download folders configured."
