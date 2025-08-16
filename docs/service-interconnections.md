# Surge Service Interconnections - Complete Auto-Configuration

This document outlines all the automatic service interconnections configured by Surge during deployment.

## 🔗 **Automatic Interconnections Configured**

### **✅ Core Automation Services**

#### **Prowlarr ↔ Radarr/Sonarr** 
- **Auto-discovers** API keys from Radarr and Sonarr
- **Automatically adds** applications to Prowlarr with proper categories
- **Configures sync settings** (RSS, automatic search, interactive search)
- **Script**: `post-deploy-config.sh` + `configure-prowlarr-direct.py`

#### **Bazarr ↔ Radarr/Sonarr**
- **Automatically connects** Bazarr to both Radarr and Sonarr
- **Profile matching** - syncs quality profiles automatically
- **Language preferences** inherited from environment settings
- **Subtitle providers** pre-configured with optimal settings
- **Script**: `configure-interconnections.py`

#### **Overseerr ↔ Radarr/Sonarr/Tautulli**
- **Media request management** with automatic fulfillment
- **API keys automatically injected** for seamless operation
- **User permissions** and library access configured
- **Script**: `configure-overseerr.py`

### **✅ Download Client Automation**

#### **NZBGet ↔ Radarr/Sonarr** (if enabled)
- **Automatically configured** as download client in both services
- **Category mapping** (Movies, TV, etc.) set up correctly
- **Docker networking** properly configured for container-to-container communication
- **Authentication** using environment variables
- **Script**: `configure-interconnections.py`

- **Real-Debrid integration** with automatic API token injection
- **Download client setup** seamlessly integrated
- **Torrentio indexer** automatically configured in Prowlarr
- **Quality filters** and category management automated
- **Script**: `configure-rdt-torrentio.py` + `configure-interconnections.py`

### **✅ Media Server Integrations**

#### **Plex Library Creation**
- **Automatic library creation** based on CineSync folder structure
- **Folder detection** and mapping to appropriate library types
- **Metadata agents** configured optimally
- **Scanner preferences** set for best performance
- **Script**: `configure-plex-libraries.py`

#### **Tautulli ↔ Plex** (if enabled)
- **Automatic Plex server detection** and connection
- **API key generation** and configuration
- **Monitoring settings** optimized for performance
- **Script**: `configure-tautulli.py`

#### **Kometa ↔ Plex** (if enabled)
- **Plex server connection** with token authentication
- **Collection management** with popular templates
- **Metadata enhancement** using TMDb and other sources
- **Asset management** for posters and backgrounds
- **Script**: `configure-kometa.py`

### **✅ Collection and Gap Analysis**

#### **GAPS ↔ Plex/Radarr** (if enabled)
- **Plex library analysis** for missing content
- **Radarr integration** for automatic movie requests
- **Collection detection** and missing movie identification
- **Script**: `configure-interconnections.py`

#### **Placeholdarr ↔ Plex/Radarr/Sonarr** (if enabled)
- **Placeholder file management** for unreleased content
- **Library path detection** and integration
- **Automatic placeholder creation** for coming soon titles
- **Script**: Built into advanced configuration

### **✅ Real-Debrid Ecosystem**


#### **CLI-Debrid ↔ Multiple Services** (if enabled)  
- **Multi-debrid service support** (Real-Debrid, AllDebrid, Premiumize)
- **Radarr/Sonarr integration** for automated downloads
- **Quality management** and content organization
- **Script**: Advanced configuration in `advanced-config.sh`

### **✅ Enhancement Services**

#### **Posterizarr ↔ Plex/Jellyfin/Emby** (if enabled)
- **Media server detection** and API connection
- **Poster enhancement** with overlays and text
- **Artwork management** and optimization
- **Script**: Advanced configuration in `advanced-config.sh`

#### **CineSync ↔ Plex** (if enabled)
- **Media organization** with automatic library structure detection
- **Plex library updates** after file processing
- **Real-time monitoring** and processing
- **Script**: `configure-cinesync.py`

## 🔧 **Configuration Trigger Points**

### **During Deployment**
1. **Post-deploy script** runs automatically after containers start
2. **Service readiness checks** ensure all services are available
3. **API key discovery** extracts keys from container configurations
4. **Interconnection setup** configures all enabled service connections

### **Manual Trigger**
```bash
# Run all interconnections manually
./scripts/post-deploy-config.sh

# Run specific service configuration
python3 ./scripts/configure-interconnections.py /opt/surge

# Configure specific services
python3 ./scripts/configure-tautulli.py /opt/surge
python3 ./scripts/configure-kometa.py /opt/surge
```

## 📊 **Verification Commands**

After deployment, verify interconnections are working:

```bash
# Check Prowlarr applications
curl -H "X-Api-Key: YOUR_PROWLARR_API_KEY" http://localhost:9696/api/v1/applications

# Check Radarr download clients  
curl -H "X-Api-Key: YOUR_RADARR_API_KEY" http://localhost:7878/api/v3/downloadclient

# Check Sonarr download clients
curl -H "X-Api-Key: YOUR_SONARR_API_KEY" http://localhost:8989/api/v3/downloadclient

# Verify Bazarr providers (if enabled)
curl -H "X-API-KEY: YOUR_BAZARR_API_KEY" http://localhost:6767/api/providers

# Check service status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## 🎯 **What This Means For You**

### **Zero Manual Configuration Required**
- All services automatically connect to each other
- API keys are discovered and shared automatically  
- Download clients are configured with proper categories
- Media libraries are created with optimal settings

### **Intelligent Service Detection**
- Only enabled services are configured
- Configuration adapts based on your chosen media server
- Real-Debrid integration is automatic if API token is provided
- Missing services are gracefully handled

### **Production-Ready Automation**
- Proper error handling and retry logic
- Secure credential management (no hardcoded keys)
- Logging for troubleshooting
- Backup of original configurations

### **Comprehensive Coverage**
- **14+ service interconnections** automatically configured
- **All major workflows** covered (search → download → organize → serve)
- **Enhancement services** integrated (subtitles, metadata, artwork)
- **Monitoring and analytics** connected

## 🚀 **Result: Fully Operational Media Stack**

After Surge deployment completes:

1. **Search for content** in Overseerr → Automatically sent to Radarr/Sonarr
2. **Radarr/Sonarr search** via Prowlarr → Finds content across all indexers  
4. **CineSync processes** files → Organized into proper library structure
5. **Plex detects** new content → Libraries updated automatically
6. **Bazarr downloads** subtitles → Added to media files
7. **Kometa enhances** metadata → Collections and artwork improved
8. **Tautulli tracks** viewing → Analytics and monitoring active

**Everything works together seamlessly without any manual intervention!**
