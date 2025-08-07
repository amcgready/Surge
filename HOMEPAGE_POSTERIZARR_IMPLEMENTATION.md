# Homepage & Posterizarr Automation - Implementation Complete

## 🎉 **COMPLETED: Homepage Dashboard & Posterizarr Poster Management**

Two new critical automation components have been added to Surge:

---

## 🏠 **Homepage Dashboard Configuration**

### **What's Been Automated**

**Homepage Dashboard (`scripts/configure-homepage.py`)**:
- ✅ **Automatic service discovery** - Detects all enabled services from environment variables
- ✅ **Dynamic service widgets** - Creates widgets with API key integration for supported services
- ✅ **Service categorization** - Organizes services into logical groups (Media Servers, Media Management, Download Clients, Monitoring & Tools)
- ✅ **API key integration** - Automatically discovers and integrates API keys for widget functionality
- ✅ **Custom bookmarks** - Adds relevant bookmarks for media management tools
- ✅ **Docker integration** - Configures Docker socket monitoring for container status
- ✅ **Responsive layout** - Automatically adjusts layout based on number of services

### **Generated Configuration Files**:
- `settings.yaml` - Main Homepage settings and theme configuration
- `services.yaml` - Service definitions with widgets and API connections
- `bookmarks.yaml` - Curated bookmarks for media management
- `docker.yaml` - Docker socket configuration for container monitoring

### **Service Widget Support**:
- **Media Servers**: Plex, Emby, Jellyfin (with statistics widgets)
- **Management**: Radarr, Sonarr, Prowlarr, Overseerr (with API integration)
- **Monitoring**: Tautulli (with API integration)
- **Download Clients**: NZBGet, RDT-Client (basic widgets)
- **Tools**: Bazarr, GAPS, Posterizarr (service links)

---

## 🎨 **Posterizarr Poster Management**

### **What's Been Automated**

**Posterizarr Configuration (`scripts/configure-posterizarr.py`)**:
- ✅ **Service integration** - Automatically connects to Radarr and Sonarr via APIs
- ✅ **Directory structure** - Creates proper asset and configuration directories
- ✅ **API source configuration** - Configures TMDB, TVDB, and FanArt.TV integration
- ✅ **Processing settings** - Sets up poster resizing, compression, and overlay capabilities
- ✅ **Asset management** - Configures separate folders for movies, TV shows, and overlays
- ✅ **Quality settings** - Optimizes poster quality and format settings
- ✅ **Notification setup** - Configures Discord webhook notifications (if available)

### **Generated Configuration**:
- `config.yaml` - Main Posterizarr configuration with service connections
- `overlays/overlays.yaml` - Example overlay templates (4K, HD, Watched indicators)
- **Directory structure**:
  ```
  Posterizarr/
  ├── config/           # Configuration files
  ├── assets/           # Poster assets
  │   ├── movies/       # Movie posters
  │   ├── tv/           # TV show posters
  │   └── overlays/     # Overlay templates
  ├── logs/             # Processing logs
  └── backups/          # Original poster backups
  ```

### **Poster Sources**:
- **TMDB** - Primary source for movie and TV posters
- **TVDB** - TV show specialized posters and artwork
- **FanArt.TV** - High-quality fan art and logos (optional)

### **Processing Features**:
- Automatic poster resizing (1000x1500 optimal)
- Quality compression (85% quality balance)
- Overlay support (quality badges, watched indicators)
- Original backup retention
- Batch processing capabilities

---

## 🚀 **Integration Points**

### **First-Time Setup Integration**:
Both configurations are automatically integrated into the deployment process:

1. **Homepage configuration** runs after service startup
2. **Posterizarr configuration** runs if `ENABLE_POSTERIZARR=true`
3. **API key discovery** happens automatically during deployment
4. **Service interconnections** are established without user intervention

### **Service Configuration Integration**:
Added to `scripts/service_config.py`:
- `configure_homepage_automation()` - Calls Homepage configuration script
- `configure_posterizarr_automation()` - Calls Posterizarr configuration script
- Both run as part of the main service configuration process

### **Status Monitoring**:
Both services are added to `scripts/interconnection-status.py`:
- **Homepage**: Monitored on port 3000
- **Posterizarr**: Monitored on port 5060
- Service availability checks included in status reports

---

## 💻 **Usage**

### **Automatic (Recommended)**
Both configurations run automatically during Surge deployment:
```bash
./surge deploy plex
```

### **Manual Execution**
Run individual configurations if needed:

```bash
# Configure Homepage dashboard
python3 scripts/configure-homepage.py

# Configure Posterizarr (if enabled)
python3 scripts/configure-posterizarr.py

# Run all service configurations
python3 scripts/service_config.py
```

### **Environment Variables**

**For Homepage**:
- `HOMEPAGE_PORT` - Dashboard port (default: 3000)
- `PLEX_TOKEN` - For Plex widget integration
- `EMBY_TOKEN` - For Emby widget integration
- `JELLYFIN_TOKEN` - For Jellyfin widget integration

**For Posterizarr**:
- `ENABLE_POSTERIZARR=true` - Enable Posterizarr service
- `POSTERIZARR_PORT` - Service port (default: 5060)
- `TMDB_API_KEY` - TMDB API key for poster sources
- `TVDB_API_KEY` - TVDB API key for TV show sources
- `FANART_TV_API_KEY` - FanArt.TV API key (optional)
- `DISCORD_WEBHOOK_URL` - Discord notifications (optional)

---

## 🎯 **Access Points**

After deployment, services are available at:

- **Homepage Dashboard**: http://localhost:3000
- **Posterizarr Interface**: http://localhost:5060 (if enabled)

### **Homepage Features**:
- 📊 **Service widgets** with real-time statistics
- 🔗 **Quick access** to all enabled services
- 🐳 **Docker container status** monitoring
- 🌐 **Curated bookmarks** for media management
- 🎨 **Dark theme** optimized for media centers

### **Posterizarr Features**:
- 🎨 **Automated poster management** for movies and TV shows
- 🏷️ **Custom overlays** (4K, HD, quality indicators)
- 📊 **Processing statistics** and logs
- 🔄 **Batch operations** for existing libraries
- 💾 **Backup management** of original artwork

---

## ✅ **Success Verification**

After deployment, you should see:

- ✅ Homepage dashboard accessible with all enabled services
- ✅ Service widgets showing real-time data (where API keys are available)
- ✅ Posterizarr configuration complete (if enabled)
- ✅ Asset directories created and configured
- ✅ API connections established to Radarr/Sonarr
- ✅ Both services listed in interconnection status reports

---

## 🛠️ **Troubleshooting**

### **Homepage Issues**:
- **Missing widgets**: Check API key availability in service config files
- **Service not showing**: Verify service is enabled in environment variables
- **Docker monitoring fails**: Ensure `/var/run/docker.sock` is accessible

### **Posterizarr Issues**:
- **No posters downloading**: Verify TMDB_API_KEY is set and valid
- **Service connections fail**: Check Radarr/Sonarr API keys are generated
- **Permission errors**: Verify storage directory permissions (PUID/PGID)

Both new automation systems significantly enhance the Surge user experience by providing a unified dashboard and automated poster management capabilities!
