# Surge Container Update System

The Surge Container Update System provides comprehensive tools for keeping your media stack containers up-to-date while preserving configurations and user settings.

## Features

- **Smart Update Detection**: Automatically detects when container updates are available
- **Configuration Preservation**: Keeps all your settings during updates
- **Discord Notifications**: Get notified when updates are available
- **Background Monitoring**: Optional service to continuously monitor for updates
- **Manual Control**: Full control over when and how updates are applied

## Quick Start

### Manual Updates

```bash
# Check for available updates
./surge --update --check

# Apply available updates
./surge --update

# Force update even if no updates detected
./surge --update --force

# Update with configuration backup
./surge --update --backup
```

### Background Monitoring

```bash
# Install and start monitoring service (requires sudo)
sudo ./scripts/update-service.sh install
sudo ./scripts/update-service.sh start

# Check monitoring status
./scripts/update-service.sh status

# Stop monitoring
sudo ./scripts/update-service.sh stop
```

## Commands Reference

### Main Update Commands

| Command | Description |
|---------|-------------|
| `./surge --update` | Check for and apply available updates |
| `./surge --update --check` | Only check for updates, don't apply |
| `./surge --update --force` | Force update regardless of detection |
| `./surge --update --backup` | Create config backup before updating |
| `./surge --update --no-cleanup` | Skip cleanup of old Docker images |

### Monitoring Service Commands

| Command | Description |
|---------|-------------|
| `sudo ./scripts/update-service.sh install` | Install monitoring service |
| `sudo ./scripts/update-service.sh start` | Start monitoring |
| `sudo ./scripts/update-service.sh stop` | Stop monitoring |
| `sudo ./scripts/update-service.sh status` | Check service status |
| `sudo ./scripts/update-service.sh configure` | Configure monitoring settings |
| `sudo ./scripts/update-service.sh uninstall` | Remove monitoring service |

### Direct Monitoring Commands

| Command | Description |
|---------|-------------|
| `./scripts/update.sh --monitor-start` | Start monitor (non-service) |
| `./scripts/update.sh --monitor-stop` | Stop monitor |
| `./scripts/update.sh --monitor-status` | Check monitor status |

## Configuration

### Environment Variables

Add these to your `.env` file to configure the update system:

```bash
# Update check interval (seconds) - default: 3600 (1 hour)
UPDATE_CHECK_INTERVAL=3600

# Enable Discord notifications - default: true
UPDATE_NOTIFICATIONS=true

# Discord webhook URL for notifications
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL
```

### Discord Notifications

To receive Discord notifications when updates are available:

1. Create a Discord webhook in your server
2. Add the webhook URL to your `.env` file:
   ```bash
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL
   ```
3. Enable notifications:
   ```bash
   UPDATE_NOTIFICATIONS=true
   ```

The system will send notifications like:
- "🔄 Surge Container Updates Available - Found updates for 3 container(s)"
- "✅ Surge Update Success - Update completed successfully!"
- "❌ Surge Update Error - Update failed during container update process"

## How It Works

### Update Detection

The system checks for updates by:
1. Pulling latest container images from registries
2. Comparing image IDs/digests with currently running containers
3. Identifying services with newer versions available

### Configuration Preservation

During updates, the system:
1. **Backs up** your `.env` file and configuration files
2. **Pulls** latest container images
3. **Recreates** containers with new images
4. **Restores** your configurations
5. **Verifies** container health after update

Protected configurations include:
- `.env` environment variables
- Service configuration files (*.yml, *.yaml, *.json, *.ini)
- API keys and user settings
- Custom service configurations

### Background Monitoring

The monitoring service:
1. Runs as a systemd service (optional)
2. Checks for updates at configurable intervals
3. Sends Discord notifications when updates are found
4. Does NOT automatically apply updates (user control)

## Examples

### Basic Usage

```bash
# Daily routine - check and apply updates
./surge --update

# Check without applying (good for scripts)
if ./surge --update --check; then
    echo "Updates available!"
    ./surge --update
fi
```

### With Backup and Monitoring

```bash
# Safe update with backup
./surge --update --backup

# Install monitoring service
sudo ./scripts/update-service.sh install
sudo ./scripts/update-service.sh configure  # Set check interval and Discord
sudo ./scripts/update-service.sh start

# Check monitoring status
./scripts/update-service.sh status
```

### Automation Examples

```bash
# Cron job to check daily (add to crontab)
0 6 * * * /path/to/surge --update --check && echo "Updates available" | mail -s "Surge Updates" user@domain.com

# Systemd timer for weekly updates
# (create update.timer and update.service)
```

## Troubleshooting

### Update Monitor Won't Start

```bash
# Check Python3 is available
python3 --version

# Check permissions
ls -la /var/log/surge-update-monitor.log

# Check systemd logs
journalctl -u surge-update-monitor
```

### Discord Notifications Not Working

```bash
# Test webhook manually
curl -X POST "YOUR_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"content": "Test notification from Surge"}'

# Check environment variables
grep DISCORD_WEBHOOK_URL .env
```

### Updates Not Detected

```bash
# Check Docker permissions
docker compose pull --dry-run

# Manually check for updates
python3 ./scripts/update-monitor.py --check-once

# Check Docker registry connectivity
docker pull your-image-name:latest
```

### Configuration Lost During Update

The system automatically backs up configurations, but you can:

```bash
# Create manual backup before update
./surge --update --backup

# Check backup location
ls -la ./backups/
```

## Advanced Configuration

### Custom Check Intervals

For different monitoring frequencies:

```bash
# Check every 30 minutes
UPDATE_CHECK_INTERVAL=1800

# Check every 6 hours  
UPDATE_CHECK_INTERVAL=21600

# Check once daily
UPDATE_CHECK_INTERVAL=86400
```

### Multiple Discord Channels

You can configure different webhooks for different types of notifications by modifying the `update-monitor.py` script or using multiple webhook URLs.

### Update Policies

Create custom update policies by modifying the update scripts:
- Only update specific services
- Update during maintenance windows
- Require manual approval for certain services

## Security Considerations

- The monitoring service runs as root (required for Docker access)
- Configuration files are preserved during updates
- API keys and credentials are maintained
- Old Docker images are cleaned up (can be disabled with `--no-cleanup`)
- All scripts validate input and handle errors gracefully

## Integration

The update system integrates with:
- **Discord**: Notifications and alerts
- **systemd**: Background monitoring service
- **Docker Compose**: Container management
- **Surge CLI**: Main command interface
- **Environment Variables**: Configuration management

This provides a complete, enterprise-ready update management system for your Surge media stack.
