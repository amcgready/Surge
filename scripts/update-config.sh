#!/bin/sh
# Surge Update Config Script
# 1. Backup user env/config files
# 2. Pull latest codebase
# 3. Restore env/config files
# 4. Detect new containers
# 5. Prompt for deployment

set -e

REPO_URL="https://github.com/amcgready/Surge.git"
BACKUP_DIR="/tmp/surge_env_backup_$(date +%s)"
SURGE_DIR="$(dirname "$0")/.."

# List of env/config files to backup (customize as needed)
ENV_FILES=".env config/overseerr/config.yml config/radarr/config.yml config/sonarr/config.yml"
COMPOSE_FILE="docker-compose.yml"

cd "$SURGE_DIR"

# Step 1: Backup env/config files
mkdir -p "$BACKUP_DIR"
echo "Backing up environment/config files to $BACKUP_DIR..."
for f in $ENV_FILES; do
  if [ -f "$f" ]; then
    cp "$f" "$BACKUP_DIR/$(basename $f)"
  fi
  if [ -d "$f" ]; then
    cp -r "$f" "$BACKUP_DIR/$(basename $f)"
  fi
done
if [ -f "$COMPOSE_FILE" ]; then
  cp "$COMPOSE_FILE" "$BACKUP_DIR/docker-compose.yml.old"
fi

# Step 2: Pull latest codebase
echo "Pulling latest codebase from $REPO_URL..."
git fetch origin
LATEST_COMMIT=$(git rev-parse origin/main)
git reset --hard "$LATEST_COMMIT"

# Step 3: Restore env/config files
echo "Restoring environment/config files..."
for f in $ENV_FILES; do
  if [ -f "$BACKUP_DIR/$(basename $f)" ]; then
    cp "$BACKUP_DIR/$(basename $f)" "$f"
  fi
  if [ -d "$BACKUP_DIR/$(basename $f)" ]; then
    cp -r "$BACKUP_DIR/$(basename $f)" "$f"
  fi
done

# Step 4: Detect new containers
if [ -f "$COMPOSE_FILE" ] && [ -f "$BACKUP_DIR/docker-compose.yml.old" ]; then
  echo "Checking for new containers in the stack..."
  NEW_CONTAINERS=$(diff "$BACKUP_DIR/docker-compose.yml.old" "$COMPOSE_FILE" | grep '^>' | grep 'container_name' | awk '{print $2}')
  if [ -n "$NEW_CONTAINERS" ]; then
    echo "New containers detected: $NEW_CONTAINERS"
    echo "Would you like to deploy the new containers? (y/n)"
    read DEPLOY
    if [ "$DEPLOY" = "y" ]; then
      docker compose up -d $NEW_CONTAINERS
      echo "New containers deployed."
    else
      echo "Skipped deploying new containers."
    fi
  else
    echo "No new containers detected."
  fi
fi

echo "Update complete."
