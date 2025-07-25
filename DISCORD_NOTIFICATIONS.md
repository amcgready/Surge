# Discord Notification Controls Test Guide

## Overview
This guide demonstrates Surge's granular Discord notification controls.

## 🔔 Notification Types

### **Container Updates** (`DISCORD_NOTIFY_UPDATES`)
- **Triggered when:** New container versions are detected during scheduled checks
- **Frequency:** Every 4 hours by default
- **Content:** List of containers with available updates
- **Recommended:** ✅ **Enabled** (important for security and features)

### **Asset Processing** (`DISCORD_NOTIFY_PROCESSING`)
- **Triggered when:** ImageMaid → Posterizarr → Kometa sequence completes, Scanly scan operations finish
- **Frequency:** Once daily (2 AM default) or manual runs
- **Content:** Processing completion summary with steps completed, new media detection results, symlink creation reports
- **Recommended:** ✅ **Enabled** (useful to know automation is working)

### **Error Alerts** (`DISCORD_NOTIFY_ERRORS`)
- **Triggered when:** Critical errors occur in any service
- **Frequency:** As errors occur
- **Content:** Error details and affected service
- **Recommended:** ✅ **Enabled** (critical for troubleshooting)

### **Media Events** (`DISCORD_NOTIFY_MEDIA`)
- **Triggered when:** Playback events via Tautulli (play/stop/pause)
- **Frequency:** Every media action
- **Content:** User, media title, action taken
- **Recommended:** ❌ **Disabled** (can be very noisy)

### **System Status** (`DISCORD_NOTIFY_SYSTEM`)
- **Triggered when:** Configuration changes, service starts/stops
- **Frequency:** During maintenance activities
- **Content:** System status updates and configuration changes
- **Recommended:** ❌ **Disabled** (low priority, can be noisy)

## 🛠️ Configuration Commands

### **Initial Setup**
```bash
# Auto mode - enables updates, processing, errors by default
./surge setup --auto

# Custom mode - choose each notification type
./surge setup --custom
```

### **Modify Existing Settings**
```bash
# Configure notification preferences
./surge config notifications

# View current settings
grep "DISCORD_NOTIFY_" .env
```

### **Example Configuration**
```bash
# Recommended settings for most users
DISCORD_NOTIFY_UPDATES=true
DISCORD_NOTIFY_PROCESSING=true
DISCORD_NOTIFY_ERRORS=true
DISCORD_NOTIFY_MEDIA=false
DISCORD_NOTIFY_SYSTEM=false
```

## 📝 Notification Examples

### **Container Update Notification**
```
Surge - Container Updates Available
Updates are available for:

• surge-radarr
• surge-kometa
• surge-tautulli

Use ./surge update to apply updates.
```

### **Asset Processing Notification**
```
Surge - Asset Processing Complete
Successfully completed:
• ImageMaid cleanup
• Posterizarr poster updates
• Kometa metadata refresh
• Scanly media scan (12 new files found)
• Symlink organization (8 files organized)
```

### **Media Detection Notification**
```
Surge - Scanly New Media Detected
Found 5 new media files:
• Movie: The Matrix Resurrections (2021)
• Movie: Dune (2021)
• TV Show: Foundation S01E01
• TV Show: Foundation S01E02
• Documentary: Free Solo (2018)
```

### **Error Alert Notification**
```
Surge - Error Alert
Service: Radarr
Error: Failed to connect to download client
Time: 2025-07-24 14:30:00
```

## 🔧 Technical Implementation

### **Service Integration**
Each notification type is checked before sending:

```bash
# Example from shared-config.sh
case "$notification_type" in
    "updates")
        if [ "${DISCORD_NOTIFY_UPDATES:-false}" != "true" ]; then
            return 0  # Skip notification
        fi
        ;;
esac
```

### **Service-Specific Configs**
- **Kometa**: Only gets webhook if `DISCORD_NOTIFY_PROCESSING=true`
- **Scanly**: Only gets webhook if `DISCORD_NOTIFY_PROCESSING=true` (includes new media detection and symlink creation events)
- **Posterizarr**: Only gets webhook if `DISCORD_NOTIFY_PROCESSING=true`
- **Tautulli**: Only gets webhook if `DISCORD_NOTIFY_MEDIA=true`
- **Watchtower**: Only gets webhook if `DISCORD_NOTIFY_UPDATES=true`

### **Environment Variables**
All notification preferences are stored in `.env`:
```bash
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
NOTIFICATION_TITLE_PREFIX=Surge
DISCORD_NOTIFY_UPDATES=true
DISCORD_NOTIFY_PROCESSING=true
DISCORD_NOTIFY_ERRORS=true
DISCORD_NOTIFY_MEDIA=false
DISCORD_NOTIFY_SYSTEM=false
```

## 🧪 Testing

### **Test Webhook**
```bash
./surge config test-webhook
```

### **Test Specific Notification Types**
```bash
# Test update notification
./surge config check-updates

# Test processing notification (run asset sequence)
./surge process sequence

# Test configuration notification
./surge config update
```

## 💡 Tips

1. **Start Conservative**: Enable only updates, processing, and errors initially
2. **Media Events**: Only enable if you want notifications for every play/pause
3. **System Status**: Useful for debugging but can be noisy during maintenance
4. **Test First**: Use `./surge config test-webhook` to verify Discord setup
5. **Adjust Over Time**: Modify preferences based on your notification tolerance

## 🔄 Migration

If you have an existing Surge installation:

1. **Run Reconfigure**: `./surge setup --reconfigure`
2. **Set Preferences**: `./surge config notifications`
3. **Update Configs**: `./surge config update`
4. **Test**: `./surge config test-webhook`

The system will automatically migrate your existing Discord webhook and set reasonable defaults for the new notification types.
