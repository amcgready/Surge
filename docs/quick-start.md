# Quick Start Guide

This guide will help you get Surge up and running quickly.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux/macOS/Windows with WSL2

## Step 1: Clone and Setup

```bash
git clone https://github.com/amcgready/Surge.git
cd Surge
```

## Step 2: Configure Environment

```bash
cp .env.example .env
nano .env  # Edit configuration
```

### Key Configuration Options

```bash
# Choose your timezone
TZ=America/New_York

# Set your user/group IDs (run 'id' to get yours)
PUID=1000
PGID=1000

# Configure storage paths
DATA_ROOT=/opt/surge
MOVIES_DIR=${DATA_ROOT}/media/movies
TV_SHOWS_DIR=${DATA_ROOT}/media/tv

# Choose default ports (or keep defaults)
HOMEPAGE_PORT=3000
PLEX_PORT=32400
RADARR_PORT=7878
SONARR_PORT=8989
```

## Step 3: Deploy

Choose your media server and deploy:

```bash
# For Plex
./scripts/deploy.sh plex

# For Emby
./scripts/deploy.sh emby

# For Jellyfin
./scripts/deploy.sh jellyfin

# Minimal deployment (core services only)
./scripts/deploy.sh plex --minimal
```

## Step 4: Access Services

Once deployed, access your services:

- **Homepage Dashboard**: http://localhost:3000
- **Plex**: http://localhost:32400/web
- **Radarr**: http://localhost:7878
- **Sonarr**: http://localhost:8989
- **Bazarr**: http://localhost:6767

## Step 5: Initial Setup

### 1. Configure Media Server

**Plex:**
1. Go to http://localhost:32400/web
2. Sign in with your Plex account
3. Add libraries pointing to `/data/movies` and `/data/tv`

**Jellyfin/Emby:**
1. Go to http://localhost:8096
2. Complete initial setup wizard
3. Add libraries pointing to `/data/movies` and `/data/tv`

### 2. Configure Radarr

1. Go to http://localhost:7878
2. Settings → Media Management → Add Root Folder: `/movies`
3. Settings → Download Clients → Add your preferred client
4. Settings → General → Copy API Key for later use

### 3. Configure Sonarr

1. Go to http://localhost:8989
2. Settings → Media Management → Add Root Folder: `/tv`
3. Settings → Download Clients → Add your preferred client
4. Settings → General → Copy API Key for later use

### 4. Configure Download Clients

**NZBGet:**
1. Go to http://localhost:6789
2. Login with `admin`/`tegbzn6789`
3. Configure your Usenet providers

1. Go to http://localhost:6500
2. Enter your Real-Debrid API token
3. Configure download paths

## Common Tasks

### Update All Services
```bash
./scripts/update.sh
```

### View Service Status
```bash
./scripts/maintenance.sh status
```

### View Logs
```bash
# All services
./scripts/maintenance.sh logs

# Specific service
./scripts/maintenance.sh logs radarr
```

### Restart Services
```bash
./scripts/maintenance.sh restart
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs
./scripts/maintenance.sh logs [service-name]

# Reset problematic service
./scripts/maintenance.sh reset [service-name]
```

### Permission Issues
```bash
# Check your PUID/PGID in .env
id

# Update .env with correct values
PUID=1000
PGID=1000
```

### Port Conflicts
Edit `.env` and change conflicting ports:
```bash
RADARR_PORT=7879  # If 7878 is in use
SONARR_PORT=8990  # If 8989 is in use
```

## Next Steps

- Read the [Configuration Guide](configuration.md) for advanced setup
- Check the [Troubleshooting Guide](troubleshooting.md) for common issues
- Join our community for support and tips
