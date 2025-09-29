#!/bin/bash
# Configure Riven with API keys and settings
# Usage: Called from deploy script if Riven is enabled

set -e

# Check if Riven is enabled (environment variable or argument)
if [ "$RIVEN_ENABLED" != "true" ]; then
  echo "Riven is not enabled. Skipping Riven configuration."
  exit 0
fi

# Path to Riven config directory (as mounted in docker-compose)
RIVEN_CONFIG_DIR="./config/riven"
SETTINGS_FILE="$RIVEN_CONFIG_DIR/settings.json"

# Ensure config directory exists
mkdir -p "$RIVEN_CONFIG_DIR"

# Collect API keys from environment
RD_API_TOKEN="${RD_API_TOKEN:-}"      # Real Debrid
AD_API_TOKEN="${AD_API_TOKEN:-}"      # All Debrid
DEBRID_LINK_API_TOKEN="${DEBRID_LINK_API_TOKEN:-}" # Debrid Link
TORBOX_API_TOKEN="${TORBOX_API_TOKEN:-}" # TorBox

# Create or update settings.json for Riven
cat > "$SETTINGS_FILE" <<EOF
{
  "real_debrid_api_key": "$RD_API_TOKEN",
  "all_debrid_api_key": "$AD_API_TOKEN",
  "debrid_link_api_key": "$DEBRID_LINK_API_TOKEN",
  "torbox_api_key": "$TORBOX_API_TOKEN"
}
EOF

echo "Riven configuration complete. API keys written to $SETTINGS_FILE"
