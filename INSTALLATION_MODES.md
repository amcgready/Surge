# Surge Installation Modes

## Overview

Surge now offers two distinct installation modes to accommodate different user preferences and technical expertise levels:

## 🚀 Auto Install Mode

**Perfect for: New users, quick deployments, standard setups**

### Features:
- **Quick Setup**: Only asks essential questions
- **Full Stack**: Deploys all 14+ services automatically
- **Smart Defaults**: Auto-detects user IDs, timezone, and optimal settings
- **Minimal Input**: Just choose media server and storage location

### What Gets Configured Automatically:
- User/Group IDs (auto-detected from current user)
- Timezone (auto-detected from system)
- All core services enabled (Radarr, Sonarr, Bazarr, NZBGet, etc.)
- Default ports for all services
- Automatic updates enabled (Watchtower)
- Asset processing scheduled (daily at 2 AM)
- Deployment type set to "full"

### Usage:
```bash
# Interactive selection
./surge setup

# Direct auto mode
./surge setup --auto
./scripts/first-time-setup.sh --auto
```

## 🔧 Custom Install Mode

**Perfect for: Power users, specific requirements, advanced configurations**

### Features:
- **Complete Control**: Configure every aspect of the deployment
- **Deployment Options**: Choose full/minimal/custom service selection
- **Service Selection**: Enable/disable individual services
- **Port Configuration**: Customize all network ports
- **API Integration**: Set up external services (TMDB, Trakt, Real-Debrid)
- **Download Clients**: Configure NZBGet and Real-Debrid settings

### Deployment Type Options:

#### 1. Full Stack
- All 14+ services enabled
- Complete automation pipeline
- All monitoring and enhancement tools

#### 2. Minimal Stack
- Core services only:
  - Media server (Plex/Emby/Jellyfin)
  - Radarr & Sonarr
  - NZBGet (downloader)
  - Tautulli (monitoring)
  - Homepage (dashboard)

#### 3. Custom Stack
- Pick and choose specific services
- Individual service enable/disable options
- Granular control over features

### Advanced Configuration Options:
- **Network Ports**: Customize all service ports
- **External APIs**: TMDB, Trakt integration
- **Download Clients**: NZBGet credentials, Real-Debrid tokens
- **Automation**: Custom scheduling, update intervals
- **Storage**: Custom paths and directory structure

### Usage:
```bash
# Interactive selection
./surge setup

# Direct custom mode
./surge setup --custom
./scripts/first-time-setup.sh --custom
```

## 🔄 Configuration Management

### New Variable Detection

Surge automatically detects when container updates introduce new configuration options:

- **Alert System**: "New Variable Detected" notifications
- **Backup & Merge**: Preserves existing settings while adding new options
- **Version Tracking**: Configuration version management
- **Update Options**: Smart merging or full reconfiguration

### Reconfiguration

```bash
# Reconfigure existing installation
./surge setup --reconfigure
./scripts/first-time-setup.sh --reconfigure
```

### Configuration Update Flow:

1. **Detection**: Script checks for config version mismatches
2. **Alert**: User is notified of available updates
3. **Options**: Choose between:
   - Merge new variables (recommended)
   - Full reconfiguration
   - Skip updates
4. **Backup**: Existing config is backed up automatically
5. **Update**: New configuration is generated with preserved settings

## 📋 Comparison Matrix

| Feature | Auto Install | Custom Install |
|---------|-------------|----------------|
| Setup Time | ~2 minutes | ~10-15 minutes |
| Questions Asked | 3-4 | 20+ |
| Service Control | All enabled | Individual choice |
| Port Configuration | Defaults | Customizable |
| API Setup | Later | During setup |
| Deployment Type | Full | Full/Minimal/Custom |
| User Experience | Beginner-friendly | Power user |
| Automation | All enabled | Configurable |

## 🎯 Recommendations

### Choose **Auto Install** if you:
- Are new to media management setups
- Want to get started quickly
- Prefer sensible defaults
- Can customize later through web interfaces
- Want the full experience without complexity

### Choose **Custom Install** if you:
- Have specific port requirements
- Want to run only certain services
- Need to integrate with existing infrastructure
- Have external API keys ready
- Prefer granular control over all settings

## 🔧 Post-Installation

Both installation modes create the same `.env` configuration file that can be manually edited later. Users can always:

- Modify service settings through web interfaces
- Edit the `.env` file directly for advanced changes
- Run `./surge setup --reconfigure` to change major settings
- Use the configuration update system when containers are updated

## 📝 Examples

### Quick Start (Auto)
```bash
git clone https://github.com/amcgready/Surge.git
cd Surge
./surge setup --auto
# Choose: Jellyfin, /opt/surge
./surge deploy jellyfin
```

### Advanced Setup (Custom)
```bash
git clone https://github.com/amcgready/Surge.git
cd Surge
./surge setup --custom
# Configure: Plex, custom ports, minimal services, API keys
./surge deploy plex
```

### Existing Installation Update
```bash
cd Surge
./surge setup --reconfigure
# Script detects configuration changes and offers update options
```
