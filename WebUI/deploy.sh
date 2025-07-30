#!/bin/sh
# Deploy the Surge WebUI setup tool using Docker Compose
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/2] Building and starting Surge WebUI containers..."
docker compose up --build -d

echo "[2/2] WebUI is running. Access it at http://localhost:3100"
