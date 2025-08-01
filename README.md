<div align="center">
  <img src="assets/Surge.png" alt="Surge Logo" width="200"/>
</div>

# Surge - Unified Media Management Stack

Surge is a comprehensive, one-stop Docker deployment solution that combines the best media management, automation, and monitoring tools into a single, easy-to-deploy stack.

## 🚀 What's Included

### Core Media Server (Choose One)
- **[Plex Media Server](https://github.com/plexinc/pms-docker)** - Premium media streaming platform
- **[Emby](https://github.com/MediaBrowser/Emby)** - Feature-rich media server with live TV support  
- **[Jellyfin](https://github.com/jellyfin/jellyfin)** - Free and open-source media server

### Media Automation & Management
- **[Radarr](https://github.com/Radarr/Radarr)** - Movie collection manager for Usenet and BitTorrent
- **[Sonarr](https://github.com/Sonarr/Sonarr)** - TV series collection manager
- **[Prowlarr](https://github.com/Prowlarr/Prowlarr)** - Indexer manager/proxy for torrent trackers and Usenet indexers
  - Includes **[Torrentio](https://github.com/dreulavelle/Prowlarr-Indexers)** custom indexer for Real-Debrid integration
- **[Bazarr](https://github.com/morpheus65535/bazarr)** - Subtitle management for Radarr and Sonarr
- **[CineSync](https://github.com/sureshfizzy/CineSync)** - Comprehensive media library management system for Movies & TV shows
- **[Placeholdarr](https://github.com/TheIndieArmy/placeholdarr)** - Creates placeholder files for undownloaded media in Plex/Jellyfin libraries

### Download Clients & Tools
- **[NZBGet](https://github.com/nzbgetcom/nzbget)** - Efficient Usenet downloader
- **[RDT-Client](https://github.com/rogerfar/rdt-client)** - Real-Debrid torrent client
- **[Zilean](https://github.com/iPromKnight/zilean)** - DebridMediaManager content search with Torznab support
- **[GAPS](https://github.com/JasonHHouse/gaps)** - Finds missing movies in Plex libraries and integrates with Radarr
- **[Zurg](https://github.com/debridmediamanager/zurg-testing)** - Real-Debrid integration testing tool
- **[cli_debrid](https://github.com/godver3/cli_debrid)** - Command-line interface for debrid services management
- **[Decypharr](https://github.com/sirrobot01/decypharr)** - QBittorrent API implementation with multiple debrid service support

### Content Enhancement
- **[Kometa](https://github.com/Kometa-Team/Kometa)** - Metadata and collection management (formerly Plex Meta Manager)
- **[ImageMaid](https://github.com/Kometa-Team/ImageMaid)** - Automated image cleanup and optimization for media libraries
- **[Posterizarr](https://github.com/fscorrupt/posterizarr)** - Automated poster generation for Plex/Jellyfin/Emby with custom overlays and text

### Monitoring & Interface
- **[Overseerr](https://github.com/sct/overseerr)** - Request management and media discovery for Plex/Emby/Jellyfin
- **[Tautulli](https://github.com/Tautulli/Tautulli)** - Plex/Emby/Jellyfin monitoring and statistics
- **[Homepage](https://github.com/gethomepage/homepage)** - Unified dashboard for all services

## 🔧 Enhanced Features

### Prowlarr with Torrentio Integration
Surge includes pre-configured **[Torrentio](https://github.com/dreulavelle/Prowlarr-Indexers)** custom indexer for Prowlarr, enabling:
- **Real-Debrid Integration** - Direct streaming from debrid services
- **Multiple Torrent Sources** - Access to YTS, EZTV, RARBG, 1337x, and more
- **Quality Filtering** - Automatic quality selection and filtering
- **IMDB Integration** - Precise movie/TV show searches using IMDB IDs

The Torrentio indexer is automatically available in Prowlarr and just needs your Real-Debrid API key for configuration.

#### Torrentio Setup Instructions:
1. Access Prowlarr at `http://localhost:9696`
2. Go to **Settings** → **Indexers** → **Add Indexer**
3. Search for "**Torrentio**" and select it
4. Enter your **Real-Debrid API key** in the configuration
5. Customize provider options and quality filters as needed
6. **Save** and the indexer will be available to Radarr/Sonarr

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 8GB RAM recommended
- Sufficient storage for media files

## 🛠️ Quick Start

### **Installation Modes**

Surge offers two installation modes to suit different user preferences:

#### 🚀 **Auto Install** (Recommended for new users)
- Quick setup with optimal defaults
- Minimal questions (media server choice + storage location)
- Auto-detects user IDs and timezone
- Deploys full stack with all features
- Perfect for getting started quickly

#### 🔧 **Custom Install** (For power users)
- Complete control over every setting
- Choose deployment type (full/minimal/custom services)
- Configure individual ports and services
- Set up API keys and external services
- Perfect for advanced configurations

### **Setup Commands**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/amcgready/Surge.git
   cd Surge
   ```

2. **Choose your installation method:**

   **Auto Install (Quick & Easy):**
   ```bash
   ./surge setup --auto
   ```
   
   **Custom Install (Full Control):**
   ```bash
   ./surge setup --custom
   ```
   
   **Interactive Mode (Choose during setup):**
   ```bash
   ./surge setup
   ```

### **Alternative Setup Methods**

**Option 1: Direct Script Execution**
```bash
# Auto installation
./scripts/first-time-setup.sh --auto

# Custom installation  
./scripts/first-time-setup.sh --custom

# Interactive mode
./scripts/first-time-setup.sh
```

**Option 2: Automated Setup (Legacy)**

2. **Deploy your stack:**
   ```bash
   ./surge deploy <your-chosen-media-server>
   ```

3. **Access your services:**
   - Homepage Dashboard: http://localhost:3000
   - Your chosen media server will be available on its default port

### **Option 2: Manual Setup**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/amcgready/Surge.git
   cd Surge
   ```

2. **Configure your setup:**
   ```bash
   cp .env.example .env
   # Edit .env with your preferences
   ```

3. **Choose your media server:**
   ```bash
   # For Plex (with full automation)
   ./surge deploy plex
   
   # For Emby  
   ./surge deploy emby
   
   # For Jellyfin
   ./surge deploy jellyfin
   
   # Minimal deployment (core services only)
   ./surge deploy plex --minimal
   ```

4. **Access your services:**
   - Homepage Dashboard: http://localhost:3000
   - Your chosen media server will be available on its default port

## � Configuration Management

### **Automatic Update Detection**

Surge automatically detects when container updates introduce new configuration variables:

- **New Variable Detected** alerts when services are updated
- Automatic backup of existing configurations  
- Smart merging of new variables with existing settings
- Option to reconfigure from scratch if needed

### **Configuration Updates**

```bash
# Check for configuration updates
./surge setup --reconfigure

# Update configuration while preserving settings
./scripts/first-time-setup.sh --reconfigure
```

### **Deployment Type Options**

When using **Custom Install**, you can choose from:

- **Full Stack** - All 17+ services and features
- **Minimal** - Core services only (media server + essential automation)  
- **Custom** - Pick and choose specific services

### **Shared Configuration System**

Surge uses a unified configuration system that automatically propagates shared settings across all services:

#### **Shared Variables Include:**
- **Discord Webhooks** - Notifications from all services
- **Trakt Integration** - List management and tracking
- **User/Group IDs** - Consistent permissions across containers
- **Timezone Settings** - Synchronized scheduling

#### **Auto-Propagation**
When you configure shared variables, they're automatically applied to:
- **Kometa** - Webhook notifications + metadata sources
- **Posterizarr** - Notifications + poster sources
- **Tautulli** - Discord integration for play/stop events
- **Radarr/Sonarr** - Notification configurations
- **Watchtower** - Update notifications

### **Configuration Commands**

```bash
# Setup shared variables (Discord, TMDB, Trakt)
./surge config setup

# Update all service configs with current shared variables
./surge config update

# Configure Discord notification preferences
./surge config notifications

# Check for container updates and send Discord notifications
./surge config check-updates

# Test Discord webhook
./surge config test-webhook
```

### **Discord Notification Controls**

Surge provides granular control over Discord notifications. You can enable/disable specific types:

#### **Notification Types:**
- **🔄 Container Updates** - When new container versions are available
- **✅ Asset Processing** - When ImageMaid → Posterizarr → Kometa sequence completes
- **⚠️ Error Alerts** - Critical errors from any service
- **🎬 Media Events** - Playback events via Tautulli (play/stop/pause)
- **🔧 System Status** - Configuration changes, service starts/stops

#### **Configuration:**
```bash
# Configure notification preferences interactively
./surge config notifications

# During setup (Auto mode enables updates/processing/errors by default)
./surge setup --auto

# During setup (Custom mode lets you choose each type)
./surge setup --custom
```

**Default Settings:**
- **Auto Install**: Enables updates, processing, and error notifications
- **Custom Install**: Lets you choose each notification type individually
- **Media Events**: Disabled by default (can be noisy)
- **System Status**: Disabled by default (low priority)

### **Discord Notifications**

When configured, Discord webhooks provide real-time notifications for:

- 🔄 **Container Updates Available**
- ✅ **Asset Processing Complete** (ImageMaid → Posterizarr → Kometa)
- ⚠️ **Error Alerts** from any service
- 🎬 **Media Events** (via Tautulli integration)
- 🔧 **Configuration Changes**

## �📁 Directory Structure

```
Surge/
├── surge                       # Main CLI interface
├── docker-compose.yml          # Core services
├── docker-compose.plex.yml     # Plex-specific services
├── docker-compose.emby.yml     # Emby-specific services  
├── docker-compose.jellyfin.yml # Jellyfin-specific services
├── docker-compose.automation.yml # Automation & scheduling
├── configs/                    # Service configurations
│   └── prowlarr/indexers/      # Custom Prowlarr indexers (Torrentio)
├── scripts/                    # Deployment and utility scripts
└── docs/                       # Documentation
```

## ⚙️ Configuration

All services can be configured through:
- Environment variables in `.env`
- Individual config files in `configs/`
- Docker Compose overrides

## 📊 Default Ports

| Service | Port | Description |
|---------|------|-------------|
| Homepage | 3000 | Main dashboard |
| Plex | 32400 | Plex Media Server |
| Emby | 8096 | Emby Server |
| Jellyfin | 8096 | Jellyfin Server |
| Overseerr | 5055 | Request management & media discovery |
| Radarr | 7878 | Movie management |
| Sonarr | 8989 | TV management |
| Prowlarr | 9696 | Indexer management + Torrentio |
| Bazarr | 6767 | Subtitle management |
| NZBGet | 6789 | Usenet downloader |
| Zilean | 8181 | DMM content search |
| GAPS | 8484 | Plex missing movies integration |
| RDT-Client | 6500 | Real-Debrid torrent client |
| Decypharr | 8282 | QBittorrent API with debrid support |
| Tautulli | 8182 | Media server stats |
| Posterizarr | 5060 | Custom poster management |

**Note**: ImageMaid, Kometa, Watchtower, and cli_debrid run as CLI/scheduled services without web interfaces.

## 🔄 Updates & Automation

Surge includes powerful automation features:

### Automatic Updates
- **Watchtower** automatically updates all containers to the latest versions
- Updates check every 24 hours by default
- Configurable update intervals and notifications

### Sequential Asset Processing
Surge automatically runs asset processing in the correct order:
1. **ImageMaid** - Cleans up and optimizes images first
2. **Posterizarr** - Manages custom posters and artwork
3. **Kometa** - Updates metadata and creates collections

**Scheduled Processing:**
```bash
# Runs daily at 2 AM by default
./surge process schedule    # View current schedule
./surge process sequence    # Run manually anytime
./surge process logs        # View processing logs
```

**Manual Processing:**
```bash
./surge process run imagemaid    # Run individual services
./surge process run posterizarr
./surge process run kometa
```

### Shared Assets
All services share the same assets folder ensuring:
- ✅ **Kometa** can access posters created by **Posterizarr**
- ✅ **Media servers** display custom artwork
- ✅ **ImageMaid** can clean up unused assets
- ✅ No duplicate files or broken links

## 🖥️ Command-Line Tool Access

Surge provides easy access to command-line tools:

```bash
```

### **Kometa (Metadata Manager)**
```bash
./surge exec kometa "--run"     # Run full metadata update
./surge exec kometa shell       # Interactive shell
```

### **cli_debrid (Debrid Management)**
```bash
./surge exec cli-debrid --help     # Show available commands
./surge exec cli-debrid status     # Check debrid service status
./surge exec cli-debrid shell      # Interactive shell
```

### **Service Shell Access**
```bash
./surge exec radarr            # Access Radarr container
./surge exec plex              # Access Plex container
./surge exec decypharr         # Access Decypharr container
./surge exec services          # Show all available services
```

## 🔧 Manual Updates

To update manually:

```bash
./surge update
```

## 🐛 Troubleshooting

See our [Troubleshooting Guide](docs/troubleshooting.md) for common issues and solutions.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

This project stands on the shoulders of giants. Special thanks to all the amazing developers of the included projects:

### Core Services
- **[Plex](https://github.com/plexinc/pms-docker)**, **[Emby](https://github.com/MediaBrowser/Emby)**, and **[Jellyfin](https://github.com/jellyfin/jellyfin)** teams
- **[Radarr](https://github.com/Radarr/Radarr)**, **[Sonarr](https://github.com/Sonarr/Sonarr)**, **[Prowlarr](https://github.com/Prowlarr/Prowlarr)**, and **[Bazarr](https://github.com/morpheus65535/bazarr)** developers
- **[Overseerr](https://github.com/sct/overseerr)** and **[Tautulli](https://github.com/Tautulli/Tautulli)** teams
- **[Homepage](https://github.com/gethomepage/homepage)** dashboard developers

### Download & Enhancement Tools
- **[NZBGet](https://github.com/nzbgetcom/nzbget)** team
- **[RDT-Client](https://github.com/rogerfar/rdt-client)** by Roger Far
- **[Zilean](https://github.com/iPromKnight/zilean)** by iPromKnight
- **[GAPS](https://github.com/JasonHHouse/gaps)** by JasonHHouse
- **[Zurg](https://github.com/debridmediamanager/zurg-testing)** by DebridMediaManager
- **[cli_debrid](https://github.com/godver3/cli_debrid)** by godver3
- **[Decypharr](https://github.com/sirrobot01/decypharr)** by sirrobot01
- **[Kometa](https://github.com/Kometa-Team/Kometa)** team (formerly Plex Meta Manager)
- **[CineSync](https://github.com/sureshfizzy/CineSync)** by sureshfizzy
- **[Placeholdarr](https://github.com/TheIndieArmy/placeholdarr)** by TheIndieArmy
- **[Posterizarr](https://github.com/fscorrupt/posterizarr)** by fscorrupt
- **[ImageMaid](https://github.com/Kometa-Team/ImageMaid)** by Kometa Team

### Custom Integrations
- **[Torrentio Indexer](https://github.com/dreulavelle/Prowlarr-Indexers)** by dreulavelle
- **[Watchtower](https://github.com/containrrr/watchtower)** team for automated updates

All project maintainers and contributors who make these incredible tools possible!

---

**Made with ❤️ for the media enthusiast community**
