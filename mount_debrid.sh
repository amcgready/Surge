#!/bin/bash

# Load STORAGE_PATH from .env file in the current directory
ENV_FILE="$(dirname "$0")/.env"
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Error: .env file not found in $(dirname "$0")"
    exit 1
fi

if [ -z "$STORAGE_PATH" ]; then
    echo "Error: STORAGE_PATH not set in .env file."
    exit 1
fi

RCLONE_CONF="${HOME}/.config/rclone/rclone.conf"

# Ensure rclone config directory exists
mkdir -p "$(dirname "$RCLONE_CONF")"

# Add or update remotes in rclone.conf
add_rclone_remote() {
    local name="$1"    sudo mount --make-rshared /mnt/mycloudpr4100/Surge/downloads/Decypharr/debrids
    local url="$2"
    if ! grep -q "^\[$name\]" "$RCLONE_CONF" 2>/dev/null; then
        cat >> "$RCLONE_CONF" <<EOF

[$name]
type = webdav
url = $url
vendor = other
EOF
        echo "Added rclone remote: $name"
    else
        echo "rclone remote $name already exists."
    fi
}

add_rclone_remote "realdebrid-webdav" "http://localhost:8282/webdav/realdebrid/"
add_rclone_remote "torbox-webdav" "http://localhost:8282/webdav/torbox/"

# Create mount directories if they don't exist
mkdir -p "$STORAGE_PATH/downloads/Decypharr/debrids/realdebrid"
mkdir -p "$STORAGE_PATH/downloads/Decypharr/debrids/torbox"

# Start rclone mounts (run in background)
rclone mount realdebrid-webdav: "$STORAGE_PATH/downloads/Decypharr/debrids/realdebrid" --vfs-cache-mode writes --uid=1000 --gid=1000 --umask=002 --daemon
rclone mount torbox-webdav: "$STORAGE_PATH/downloads/Decypharr/debrids/torbox" --vfs-cache-mode writes --uid=1000 --gid=1000 --umask=002 --daemon

echo "WebDAV mounts started. You can now access files in your file explorer and containers."