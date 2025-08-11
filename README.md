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
- **[GAPS](https://github.com/JasonHHouse/gaps)** - Finds missing movies in Plex libraries and integrates with Radarr
- **[pd_zurg](https://github.com/I-am-PUID-0/pd_zurg)** - Real-Debrid filesystem mounting and integration tool
- **[cli_debrid](https://github.com/godver3/cli_debrid)** - Web interface and CLI for debrid services management
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

### 🌐 RDT-Client Full Automation
Surge now includes **complete RDT-Client automation** that eliminates all manual configuration:

#### ✨ **Zero-Configuration Setup**
- **Automatic Real-Debrid Integration**: Uses your RD_API_TOKEN from setup
- **Torrentio Indexer**: Automatically configured in Prowlarr with your Real-Debrid credentials
- **Download Client Setup**: Seamlessly integrated with Radarr and Sonarr
- **No Manual Steps**: Everything configured during deployment

#### 🔧 **What Gets Automated**
- ✅ RDT-Client container configuration with Real-Debrid API token
- ✅ Torrentio indexer added to Prowlarr with quality filters and provider settings
- ✅ RDT-Client configured as download client in Radarr (movies)
- ✅ RDT-Client configured as download client in Sonarr (TV shows)
- ✅ Proper category management and Docker networking
- ✅ SSL and security settings optimized

#### 🚀 **Ready-to-Use Results**
After deployment with RDT-Client enabled:
- **Immediate Functionality**: Search and download torrents via Real-Debrid
- **Integrated Workflow**: Radarr/Sonarr → Torrentio → RDT-Client → Real-Debrid
- **Quality Control**: Automatic quality filtering and provider selection
- **Secure Configuration**: No exposed credentials or hardcoded paths
- **Security Auditing**: Built-in security audit with `./surge security-audit`

#### Manual Setup (Legacy - Not Required)
*For reference only - this is now fully automated:*
1. ~~Access Prowlarr at `http://localhost:9696`~~
2. ~~Go to **Settings** → **Indexers** → **Add Indexer**~~
3. ~~Search for "**Torrentio**" and select it~~
4. ~~Enter your **Real-Debrid API key** in the configuration~~
5. ~~Customize provider options and quality filters as needed~~
6. ~~**Save** and the indexer will be available to Radarr/Sonarr~~

**💡 With Surge's automation, simply enable RDT-Client during setup and everything is configured automatically!**

## 🤖 Complete Automation & Integrations

Surge goes far beyond simple container deployment - it provides **complete automation** of service configurations and inter-service connections. Here's everything that gets automatically configured during deployment:

### 🔗 Automatic Service Connections

#### **Prowlarr Integration Hub**
- **Auto-discovers API keys** from Radarr, Sonarr, and Bazarr
- **Automatically adds applications** to Prowlarr:
  - Radarr configured with proper categories (movies)
  - Sonarr configured with proper categories (tv, anime)
  - All sync settings optimized (RSS, automatic search, interactive search)
- **Pre-configured indexers** including Torrentio for Real-Debrid integration
- **Quality filters** automatically applied based on service requirements

#### **Download Client Automation**
- **RDT-Client** automatically configured in Radarr and Sonarr when enabled
- **NZBGet** automatically added as download client with proper categories
- **Docker networking** properly configured for container-to-container communication
- **Download paths** mapped correctly across all services

#### **Subtitle Integration**
- **Bazarr automatically connects** to both Radarr and Sonarr
- **Profile matching** - automatically syncs quality profiles
- **Language preferences** inherited from environment settings
- **Subtitle providers** pre-configured with optimal settings

### 🎯 API Key Management

#### **Automatic Discovery & Configuration**
- **Scans container configurations** to discover generated API keys
- **Waits for services to initialize** and generate their API keys
- **Automatically injects API keys** between connected services
- **Validates connections** and retries failed configurations
- **No manual copy/paste** of API keys required

#### **Services Automatically Connected**
- **Prowlarr ↔ Radarr**: Movie indexer management
- **Prowlarr ↔ Sonarr**: TV show indexer management  
- **Bazarr ↔ Radarr**: Movie subtitle automation
- **Bazarr ↔ Sonarr**: TV subtitle automation
- **Overseerr ↔ Radarr**: Movie request fulfillment
- **Overseerr ↔ Sonarr**: TV request fulfillment
- **GAPS ↔ Radarr**: Missing movie detection and automation
- **GAPS ↔ Plex**: Library analysis for missing content

### 📊 Quality Profile Automation

#### **Optimized Defaults**
- **Radarr**: HD-1080p profile set as default with proper quality cutoffs
- **Sonarr**: HD-720p/1080p profile configured for TV content
- **Bazarr**: Multi-language subtitle profiles with fallback options
- **Size limits** configured to prevent excessive downloads
- **Quality preferences** aligned across all services

#### **Real-Debrid Optimization**
When RDT-Client is enabled:
- **Torrentio indexer** configured with Real-Debrid specific settings
- **Quality filters** optimized for cached content availability
- **Provider priorities** set to prefer cached/instant downloads
- **Timeout settings** configured for debrid service reliability

### 🔄 Metadata & Content Enhancement

#### **Automatic Pipeline Configuration**
- **ImageMaid**: Configured to clean up media library artwork
- **Posterizarr**: Set up with custom poster generation for your media server
- **Kometa**: Configured with metadata sources and collection generation
- **Sequential processing**: Services run in optimal order to avoid conflicts

#### **Media Server Integration**
- **Plex/Emby/Jellyfin**: Automatically detected and configured in dependent services
- **Library paths**: Mapped consistently across all services
- **Webhook notifications**: Configured for real-time updates
- **Metadata providers**: TMDB, TVDB, and other sources configured

### 🔔 Notification Automation

#### **Discord Integration**
When Discord webhook is provided:
- **Update notifications**: Container updates and deployment status
- **Processing alerts**: Asset processing pipeline completion
- **Error monitoring**: Service failures and configuration issues
- **Media events**: Play/stop/pause events via Tautulli (optional)
- **Request notifications**: New media requests via Overseerr

#### **Service-Specific Notifications**
- **Radarr/Sonarr**: Download completion, failed downloads, health issues
- **Bazarr**: Subtitle download status, missing subtitle alerts
- **Watchtower**: Container update notifications with detailed change logs
- **GAPS**: Missing movie detection reports

### 🛡️ Security & Networking

#### **Automatic Security Configuration**
- **Internal Docker networking**: Services communicate securely without exposing ports
- **API key rotation**: Supports automatic regeneration when needed
- **SSL configuration**: HTTPS enabled where supported
- **Access controls**: Default security settings applied to all services

#### **Path Management**
- **Consistent volume mapping**: All services use standardized paths
- **Permission automation**: User/group IDs applied consistently
- **Backup integration**: Important configs automatically identified for backup

### 🎮 Advanced Automation Features

#### **Health Monitoring**
- **Service health checks**: Automatic monitoring of all containers
- **Dependency management**: Services wait for dependencies before starting
- **Restart policies**: Smart restart logic for failed services
- **Performance monitoring**: Resource usage tracking and alerts

#### **Update Management**
- **Staged updates**: Critical services updated in proper sequence
- **Configuration preservation**: User settings maintained through updates
- **Rollback capability**: Automatic backup before major changes
- **Update notifications**: Advanced Discord alerts with change details

#### **Custom Integration Points**
- **Torrentio indexer**: Pre-loaded in Prowlarr with optimal settings
- **Real-Debrid automation**: Complete zero-touch configuration
- **Custom scripts**: Hook points for additional automation
- **API discovery**: Automatic detection of new service capabilities

### 🚀 Zero-Configuration Results

After Surge deployment, you get:
- **Fully connected ecosystem**: All services talking to each other
- **Optimized workflows**: Download → Process → Organize → Notify
- **Intelligent automation**: Quality control, duplicate detection, error handling
- **Unified management**: Single dashboard controlling entire stack
- **Production-ready**: No manual configuration steps required

**This level of automation means you can go from initial setup to a fully operational media management system in under 10 minutes, with zero manual configuration required.**

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

3. **Deploy your stack:**
   ```bash
   ./surge deploy <your-chosen-media-server>
   ```

4. **Access your services:**
   - Homepage Dashboard: http://localhost:3000
   - Your chosen media server will be available on its default port

### **Alternative Setup Methods**

**Manual Configuration:**
```bash
# Clone and configure manually
git clone https://github.com/amcgready/Surge.git
cd Surge
cp .env.example .env
# Edit .env with your preferences

# Deploy with chosen media server
./surge deploy plex     # or emby/jellyfin
```

**Direct Script Execution:**
```bash
# Auto installation
./scripts/first-time-setup.sh --auto

# Custom installation  
./scripts/first-time-setup.sh --custom

# Interactive mode
./scripts/first-time-setup.sh
```

## 🎬 Demos

### Complete Workflow Demo
![Surge Complete Workflow](https://p76.tr0.n0.cdn.zight.com/items/rRuR9rve/fc44b7dd-3369-45ef-890b-457e75abecf6.gif?source=viewer&v=f2c9550a59807dfe236b82dddadd8557)

*This demonstrates the complete Surge experience from initial setup through deployment and configuration. Watch as the system automatically detects prerequisites, configures services, deploys containers, discovers API keys, and establishes inter-service connections - all in under 2 minutes.*

### Deployment Process
![Surge Deployment](https://p76.tr0.n0.cdn.zight.com/items/jkuklxZn/06af7fa8-4604-42b3-b763-51e0e0869e0f.gif?source=viewer&v=63055bb86fbd71801ca2746ef581cbfa)

*Watch the deployment process in action as Surge pulls container images, starts services, creates directory structures, and automatically configures API connections between all services. The deployment includes real-time progress updates and health checks to ensure everything is running perfectly.*

### Automatic Updates
![Surge Update Process](https://p76.tr0.n0.cdn.zight.com/items/WnunGo7A/ecea1c6b-c782-4896-a3ec-ef02bcdd7ee5.gif?source=viewer&v=65b36f64a7f546cdd73e5781508bc3a8)

*The update system automatically checks for new container versions, backs up configurations, pulls latest images, recreates containers, and sends Discord notifications - all while preserving your settings and data.*

### Key Demo Features
- **🚀 One-Command Setup**: Interactive wizard guides you through configuration
- **⚡ Automated Deployment**: Deploy your entire media stack with a single command  
- **🔄 Zero-Downtime Updates**: Update all containers while preserving configurations
- **📱 Discord Integration**: Real-time notifications for updates and system events
- **🏥 Health Monitoring**: Automatic verification that all services are operational

### Try the Demos Yourself
```bash
# Clone and test the demo scripts (safe for recording)
git clone https://github.com/amcgready/Surge.git
cd Surge

# Setup wizard demo
./scripts/test-setup-demo.sh

# Deployment demo  
./scripts/test-deploy-demo.sh

# Update process demo
./scripts/test-update-demo.sh
```

*All demo scripts use sanitized data and masked API keys - perfect for screen recordings and documentation.*

## 🔧 Configuration Management

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

# Fix directory ownership for Docker containers
./surge fix-ownership [path]

# Configure Overseerr with service API keys
./surge configure-overseerr
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
| GAPS | 8484 | Plex missing movies integration |
| RDT-Client | 6500 | Real-Debrid torrent client |
| Decypharr | 8282 | QBittorrent API with debrid support |
| Tautulli | 8182 | Media server stats |
| Posterizarr | 5060 | Custom poster management |
| cli_debrid | 5000 | Debrid services web interface |

**Note**: ImageMaid, Kometa, and Watchtower run as CLI/scheduled services without web interfaces.

## 🔄 Updates & Automation

Surge includes powerful automation features:

### Automatic Updates
- **Watchtower** automatically updates all containers to the latest versions
- Updates check every 24 hours by default
- Configurable update intervals and notifications

## 🔒 Security

Surge prioritizes security with multiple layers of protection:

### Security Features
- **Environment Variables**: All sensitive data stored in `.env` files
- **No Hardcoded Credentials**: All API keys and passwords use variable substitution
- **Secure Defaults**: Services run with non-root users when possible
- **Network Isolation**: Internal Docker networking with minimal port exposure
- **Git Security**: Comprehensive `.gitignore` prevents credential leaks

### Security Tools
```bash
# Run comprehensive security audit
./surge security-audit

# Check for exposed secrets
./surge troubleshoot

# Review service configurations
./surge status
```

### Security Best Practices
1. **Change default passwords** in your `.env` file
2. **Use strong, unique API keys** for all services
3. **Regularly update** containers with `./surge update`
4. **Monitor access logs** for suspicious activity
5. **Keep host system updated** and secured

> 📖 See `SECURITY.md` for detailed security guidelines and incident response procedures.

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

**Web Interface**: Available at http://localhost:5000 (when enabled)

**CLI Commands**:
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

## 🔧 Updates

To update all containers:

```bash
./surge --update
```

To check for updates without applying them:

```bash
./surge --update --check
```

## 🐛 Troubleshooting

See our [Troubleshooting Guide](docs/troubleshooting.md) for common issues and solutions.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🚀 Feature Roadmap

### 📅 Planned
- 🎬 Jellyseerr
- 📩 Requestrr
- 🤖 Doplarr
- 🧩 Riven
- 📊 Streammystats
- 📈 Jellystat
- 🧭 Jackett
- 📁 blackhole
- ⏳ zilean
- ☄️ comet
- 💡 recommendarr
- 📜 watchlistarr
- 🌐 traefik
- 🌀 unmaniac
- 💾 qdebrid
- 📂 debriddav
- 📂 nzbdav
- 🖥️ portainer
- 📚 mkdocs
- 🖥️ portainer
- 🎞️ handbrake
- 🦄 UnicornTranscoder
- 📡 Clusterplex
- ♻️ Tdarr
- 🔒 gluetun
- ♻️ recyclarr
- 🌿 Parsely
- 🌱 Scanly
- ➕ Ability to add multiple Sonarr and Radarr instances
- 🛠️ Ability to choose type of server deployment (video server, audio server, book server, comics server)
- 🐳 Installation for Docker if needed
- 🍏 macOS setup/deployment wizard
- 🪟 Windows setup/deployment wizard

### 🛠️ In Development
- 🌐 WebUI
- 🎥 Emby Integration
- 📺 Jellyfin Integration
- 🗂️ Kometa
- 🏠 Homepage

### 🧪 Testing
- 📦 pd-zurg
- 🔄 Autoupdater
- 📝 Placeholdarr
- 📡 RDT-Client
- 🗄️ cli_debrid
- 🔍 Decypharr
- 🗂️ Kometa
- 🖼️ ImageMaid
- 🎨 Posterizarr

### ✅ Released
- 🎬 Radarr
- 🎬 Sonarr
- 🌐 Prowlarr with Torrentio indexer
- 🗣️ Bazarr
- 🎥 CineSync
- 📥 NZBGet
- 🔍 GAPS
- 🎯 Overseerr
- 📊 Tautulli


---

**Made with ❤️ for the media enthusiast community**
