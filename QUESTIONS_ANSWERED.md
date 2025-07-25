# Surge Q&A - Your Questions Answered

## ❓ Your Questions & ✅ Our Solutions

### 1. **"Does this deploy everything at once?"**

**✅ YES** - Surge deploys everything you need in one command:

```bash
./surge deploy plex    # Deploys ALL services configured for Plex
```

**What gets deployed:**
- Your chosen media server (Plex/Emby/Jellyfin)
- All automation tools (Radarr, Sonarr, Bazarr, etc.)
- Download clients (NZBGet, RDT-Client)
- Asset management (ImageMaid, Posterizarr, Kometa)
- Monitoring (Tautulli, Homepage dashboard)
- Automatic updates (Watchtower)
- Sequential scheduling system

**Deployment Options:**
```bash
./surge deploy plex           # Full deployment (recommended)
./surge deploy plex --minimal # Core services only
```

---

### 2. **"If there is an update to the original Plex container, is it updated here? Same for all other containers?"**

**✅ YES** - Surge includes **Watchtower** for automatic updates:

**Automatic Updates:**
- ✅ **Plex, Emby, Jellyfin** - Official containers auto-update
- ✅ **Radarr, Sonarr, Bazarr** - LinuxServer.io containers auto-update  
- ✅ **All other services** - Official upstream containers auto-update
- ✅ **Custom intervals** - Default 24 hours, configurable
- ✅ **Zero downtime** - Rolling updates with health checks

**Configuration:**
```bash
# In .env file
WATCHTOWER_INTERVAL=86400    # 24 hours (customizable)
ENABLE_AUTO_UPDATES=true     # Enable/disable
```

**Manual Updates:**
```bash
./surge update    # Force update all containers immediately
```

**Update Sources:**
- **Plex**: `plexinc/pms-docker:latest` (Official Plex)
- **Radarr**: `lscr.io/linuxserver/radarr:latest` (LinuxServer)
- **Sonarr**: `lscr.io/linuxserver/sonarr:latest` (LinuxServer)
- **Jellyfin**: `jellyfin/jellyfin:latest` (Official Jellyfin)
- **All others**: Official upstream repositories

---

### 3. **"Do all parts have access to the same volumes? We need shared assets folder."**

**✅ YES** - Shared assets folder implemented across ALL services:

**Shared Volume Structure:**
```
shared-assets/          # 🎯 All services access this folder
├── posters/           # Custom posters from Posterizarr
├── backgrounds/       # Background images  
├── collections/       # Collection artwork
└── metadata/          # Metadata assets

movies/                # Your movie files
tv/                    # Your TV show files
```

**Service Access:**
- ✅ **Plex**: `/config/Library/Application Support/Plex Media Server/Metadata/Assets` → `shared-assets`
- ✅ **Emby**: `/config/metadata/assets` → `shared-assets`
- ✅ **Jellyfin**: `/config/metadata/assets` → `shared-assets`
- ✅ **Kometa**: `/assets` → `shared-assets`
- ✅ **Posterizarr**: `/assets` → `shared-assets`
- ✅ **ImageMaid**: `/assets` → `shared-assets`

**Benefits:**
- 🎯 **No duplicate files** - Single source of truth
- 🎯 **Consistent artwork** - All services see same assets
- 🎯 **Easy management** - One folder to rule them all
- 🎯 **Automatic cleanup** - ImageMaid removes unused assets

---

### 4. **"Can we schedule ImageMaid → Posterizarr → Kometa sequence?"**

**✅ YES** - Sequential processing is built-in and automated:

**Automatic Daily Schedule:**
```
2:00 AM Daily:
Step 1: ImageMaid runs (cleans up old assets)
  ↓ (waits for completion)
Step 2: Posterizarr runs (creates new posters)  
  ↓ (waits for completion)
Step 3: Kometa runs (updates metadata & collections)
```

**Manual Control:**
```bash
# Run the full sequence manually
./surge process sequence

# Run individual services
./surge process run imagemaid
./surge process run posterizarr  
./surge process run kometa

# View schedule and logs
./surge process schedule
./surge process logs
```

**Configuration:**
```bash
# In .env file
ASSET_PROCESSING_SCHEDULE="0 2 * * *"  # Daily at 2 AM (customizable)
ENABLE_SCHEDULER=true                   # Enable/disable
```

**Why This Order Works:**
1. **ImageMaid first**: Cleans up unused/broken assets
2. **Posterizarr second**: Creates new custom posters  
3. **Kometa last**: Updates metadata using clean, fresh assets

---

## 🚀 **Complete Solution Summary**

### ✅ **Question 1 - Deploy Everything**: 
Single command deploys entire stack with all integrations

### ✅ **Question 2 - Automatic Updates**: 
Watchtower monitors and updates all containers from official sources

### ✅ **Question 3 - Shared Volumes**: 
All services share the same assets folder for seamless integration

### ✅ **Question 4 - Sequential Scheduling**: 
Built-in cron scheduler runs ImageMaid → Posterizarr → Kometa in perfect order

---

## 🎯 **Real-World Usage**

**Day 1 - Deploy:**
```bash
git clone https://github.com/amcgready/Surge.git
cd Surge
cp .env.example .env
# Edit .env with your preferences
./surge deploy plex
```

**Day 2+ - Hands Off:**
- ✅ Watchtower updates containers automatically
- ✅ Scheduler runs asset processing at 2 AM daily  
- ✅ All services share the same assets seamlessly
- ✅ Homepage shows everything in one dashboard

**Manual Control When Needed:**
```bash
./surge status                    # Check everything
./surge process sequence          # Manual asset processing
./surge update                    # Force updates
./surge logs                      # View all logs
```

---

**🎬 Surge delivers exactly what you asked for: A unified, automated, self-maintaining media stack! 🚀**
