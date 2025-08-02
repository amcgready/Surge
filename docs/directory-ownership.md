# Directory Ownership Configuration

## Overview

Surge Docker containers run with specific user and group IDs (PUID:PGID) to ensure proper file permissions. By default, these are set to `1000:1000`, but they can be customized in your `.env` file.

## Why Ownership Matters

- **Overseerr**: Stores configuration in `settings.json` file that requires proper ownership
- **All Services**: Need read/write access to their config directories and media/download folders
- **File Permissions**: Prevents "permission denied" errors when containers try to create or modify files

## Automatic Ownership Setup

### During Deployment

Ownership is automatically set when you deploy Surge:

```bash
# Using the deploy script
./surge deploy plex

# Using the first-time setup
./scripts/first-time-setup.sh
```

Both methods will:
1. Create the directory structure
2. Set ownership to match your PUID:PGID configuration
3. Ensure containers can access their files

### Manual Ownership Fix

If you encounter permission issues, you can fix ownership manually:

```bash
# Fix ownership for default storage path
./surge fix-ownership

# Fix ownership for custom path
./surge fix-ownership /path/to/your/storage

# Fix ownership using environment variable
./surge fix-ownership $STORAGE_PATH
```

## Configuration

### Environment Variables

In your `.env` file:

```bash
# User and Group IDs (default: 1000:1000)
PUID=1000
PGID=1000

# Storage path
STORAGE_PATH=/opt/surge
```

### Finding Your User/Group IDs

```bash
# Your current user ID
id -u

# Your current group ID  
id -g

# Both together
id
```

## Common Issues

### Overseerr Config Locked

**Problem**: Overseerr configuration directory is locked/inaccessible

**Solution**:
```bash
# Fix ownership for your storage path
./surge fix-ownership

# Or specifically for Overseerr
sudo chown -R 1000:1000 $STORAGE_PATH/Overseerr
```

### Permission Denied Errors

**Problem**: Containers can't create or modify files

**Solution**:
1. Check your PUID/PGID settings in `.env`
2. Run the ownership fix script
3. Restart affected containers

```bash
./surge fix-ownership
docker-compose restart
```

### Custom User/Group

If you want to run containers as a different user:

1. Update your `.env` file:
```bash
PUID=1001
PGID=1001
```

2. Fix ownership:
```bash
./surge fix-ownership
```

3. Restart containers:
```bash
docker-compose restart
```

## Directory Structure

The ownership fix applies to these directories:

```
$STORAGE_PATH/
├── config/           # Service configurations
│   ├── Overseerr/   # settings.json and other configs
│   ├── Radarr/      # config.xml
│   ├── Sonarr/      # config.xml
│   └── ...
├── downloads/        # Download client files
├── logs/            # Service logs
└── media/           # Media files
    ├── movies/
    ├── tv/
    └── music/
```

## Verification

Check if ownership is correct:

```bash
# Check ownership of storage directory
ls -la $STORAGE_PATH

# Check specific service config
ls -la $STORAGE_PATH/Overseerr/config/

# Verify current PUID/PGID
grep -E '^(PUID|PGID)=' .env
```

Expected output should show your PUID:PGID values (typically `1000 1000`) as the owner.
