# Surge Shared Configuration System

## Overview

The Surge shared configuration system ensures that settings like Discord webhooks, API keys, and other variables are automatically propagated to ALL relevant services. This eliminates the need to configure each service individually and ensures consistency across your entire media stack.

## 🔄 How It Works

### **Unified Variable Management**
When you configure shared variables (Discord webhook, TMDB API key, etc.), they are:

1. **Stored in .env** - Central configuration file
2. **Auto-propagated** - Automatically applied to all relevant service configs
3. **Synchronized** - Changes update all services simultaneously
4. **Validated** - Settings are tested and verified

### **Supported Shared Variables**

| Variable | Services Using It | Purpose |
|----------|-------------------|---------|
| `DISCORD_WEBHOOK_URL` | Kometa, Scanly, Posterizarr, Tautulli, Watchtower, Scheduler | Notifications for all events |
| `TMDB_API_KEY` | Kometa, Posterizarr, Scanly | Metadata and poster downloads |
| `TRAKT_CLIENT_ID/SECRET` | Kometa | List management and tracking |
| `NOTIFICATION_TITLE_PREFIX` | All services | Consistent notification branding |
| `PUID/PGID` | All containers | Consistent file permissions |
| `TIMEZONE` | All containers | Synchronized scheduling |

## 🔔 Discord Notification System

### **Automatic Notifications For:**

#### **Container Updates**
- 🔄 **Update Available**: When new container versions are detected
- ⚡ **Update Applied**: When Watchtower updates containers
- 📊 **Update Summary**: Lists of updated services

#### **Asset Processing**
- 🎬 **Processing Started**: When ImageMaid → Posterizarr → Kometa sequence begins
- ✅ **Processing Complete**: When all three steps finish successfully
- ⚠️ **Processing Errors**: If any step fails

#### **Media Events**
- ▶️ **Playback Events**: New plays, stops (via Tautulli)
- 📁 **New Media**: When new movies/shows are added
- 🔍 **Scan Complete**: When Scanly finishes media scans

#### **System Events**
- 🔧 **Configuration Changes**: When shared config is updated
- ⚙️ **Service Status**: When services start/stop/restart
- 🚨 **Error Alerts**: Critical errors from any service

### **Notification Format**
All notifications follow a consistent format:
```
**[Prefix] - Event Title**
Event description with details
• Bullet points for lists
• Service names and timestamps
```

## 📋 Configuration Propagation

### **Service-Specific Implementations**

#### **Kometa (`config/kometa/config.yml`)**
```yaml
webhooks:
  error: [DISCORD_WEBHOOK_URL]
  version: [DISCORD_WEBHOOK_URL]
  run_start: [DISCORD_WEBHOOK_URL]
  run_end: [DISCORD_WEBHOOK_URL]

tmdb:
  apikey: [TMDB_API_KEY]

trakt:
  client_id: [TRAKT_CLIENT_ID]
  client_secret: [TRAKT_CLIENT_SECRET]
```

#### **Scanly (`config/scanly/config.yml`)**
```yaml
notifications:
  discord:
    enabled: true
    webhook_url: [DISCORD_WEBHOOK_URL]
    events: [scan_complete, errors, new_files]

metadata:
  tmdb:
    api_key: [TMDB_API_KEY]
```

#### **Posterizarr (`config/posterizarr/config.yml`)**
```yaml
notifications:
  discord:
    enabled: true
    webhook_url: [DISCORD_WEBHOOK_URL]
    notify_on: [poster_updated, errors, batch_complete]

sources:
  tmdb:
    api_key: [TMDB_API_KEY]
```

#### **Tautulli (`config/tautulli/config.ini`)**
```ini
[Webhooks]
discord_webhook_url = [DISCORD_WEBHOOK_URL]
discord_enabled = 1
discord_events = play,stop,error
```

#### **Watchtower (Docker Environment)**
```yaml
environment:
  - WATCHTOWER_NOTIFICATION_URL=[DISCORD_WEBHOOK_URL]
```

## 🛠️ Commands

### **Setup Commands**
```bash
# Interactive setup of all shared variables
./surge config setup

# Quick setup via first-time configuration
./surge setup --auto    # Includes Discord webhook prompt
./surge setup --custom  # Full configuration including Discord
```

### **Management Commands**
```bash
# Update all service configs with current shared variables
./surge config update

# Check for container updates and send notifications
./surge config check-updates

# Test Discord webhook functionality
./surge config test-webhook
```

### **Direct Script Access**
```bash
# Call shared config script directly
./scripts/shared-config.sh setup
./scripts/shared-config.sh propagate
./scripts/shared-config.sh check-updates
./scripts/shared-config.sh test-webhook
```

## 🔄 Update Detection & Notifications

### **Automatic Update Checking**
- **Scheduled Checks**: Every 4 hours via cron scheduler
- **Manual Checks**: `./surge config check-updates`
- **Pull-Based**: Pulls latest images and compares
- **Smart Detection**: Only notifies when actual updates are available

### **Update Notification Process**
1. **Image Pull**: Download latest versions of all Surge containers
2. **Comparison**: Compare current vs latest image IDs
3. **Detection**: Identify which containers have updates
4. **Notification**: Send Discord alert with update list
5. **Logging**: Record all checks and results

### **Notification Content**
```
**Surge - Container Updates Available**
Updates are available for:

• surge-radarr
• surge-kometa  
• surge-tautulli

Use ./surge update to apply updates.
```

## 🧪 Testing & Validation

### **Webhook Testing**
```bash
# Test Discord webhook
./surge config test-webhook

# Expected output in Discord:
# "Surge - Webhook Test"
# "This is a test notification from Surge shared configuration system."
```

### **Configuration Validation**
- **Syntax Checking**: All generated configs are validated
- **Service Testing**: Test connections to external APIs
- **Notification Testing**: Verify webhook delivery
- **Permission Checking**: Validate file system permissions

## 🔧 Troubleshooting

### **Common Issues**

#### **Discord Notifications Not Working**
1. **Check Webhook URL**: Ensure URL is correct and active
2. **Test Webhook**: Use `./surge config test-webhook`
3. **Check Logs**: Look at service logs for errors
4. **Permissions**: Ensure containers can reach Discord

#### **Configuration Not Propagating**
1. **Run Update**: `./surge config update`
2. **Check .env**: Verify variables are in `.env` file
3. **Restart Services**: Some configs require container restart
4. **Check Syntax**: Validate generated config files

#### **Updates Not Detected**
1. **Manual Check**: Run `./surge config check-updates`
2. **Check Schedule**: Verify cron scheduler is running
3. **Docker Access**: Ensure scheduler can access Docker socket
4. **Network Access**: Verify container can pull images

### **Debug Commands**
```bash
# Check shared config system status
./scripts/shared-config.sh help

# Manually propagate config (with debug output)
./scripts/shared-config.sh propagate

# Check scheduler logs
./surge logs scheduler

# Check automation logs  
docker logs surge-scheduler
```

## 📈 Benefits

### **Consistency**
- All services use the same notification settings
- Unified branding and formatting
- Synchronized API keys and credentials

### **Efficiency**
- Configure once, apply everywhere
- No need to individually setup each service
- Automatic propagation of changes

### **Reliability**
- Centralized configuration management
- Automatic validation and testing
- Consistent error handling

### **Maintainability**
- Easy to update settings across all services
- Clear audit trail of configuration changes
- Version tracking and rollback capabilities

## 🚀 Future Enhancements

### **Planned Features**
- **Slack Integration**: Additional webhook types
- **Email Notifications**: SMTP configuration
- **Telegram Support**: Bot-based notifications
- **Advanced Filtering**: Customize which events trigger notifications
- **Notification Scheduling**: Quiet hours and frequency limits
- **Health Monitoring**: Service availability notifications
