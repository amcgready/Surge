# ✅ Fixed: Path Configuration for Zurg → CineSync → Plex Integration

## 🎯 **Problem Solved**

**Issue**: Hardcoded paths and incorrect CineSync source configuration
**Solution**: All paths now use `${STORAGE_PATH}` and CineSync properly configured to use Zurg's `__all__` folder

## 📁 **Corrected Path Flow**

### **1. Zurg (FUSE Virtual Filesystem)**
```bash
# Zurg creates virtual files here:
${STORAGE_PATH}/Zurg/__all__/
├── movies/          # Virtual movie files from Real Debrid
├── shows/           # Virtual TV show files  
└── anime/           # Virtual anime files
```

### **2. CineSync (Source → Destination Processor)**  
```bash
# Source (reads from):
SOURCE_DIR=${STORAGE_PATH}/Zurg/__all__

# Destination (organizes to):
DESTINATION_DIR=${STORAGE_PATH}/media/
├── movies/          # Organized movies (Movies library)
├── tv/              # Organized TV shows (TV Shows library)  
├── movies/anime/    # Organized anime movies (Anime Movies library)
└── tv/anime/        # Organized anime series (Anime Series library)
```

### **3. Plex (Media Server)**
```bash
# Plex scans these organized folders:
/data/movies  → ${STORAGE_PATH}/media/movies
/data/tv      → ${STORAGE_PATH}/media/tv
```

## 🔧 **Docker Compose Changes Made**

### **Zurg Service - Fixed Volumes**
```yaml
volumes:
  - ${STORAGE_PATH}/Zurg/config:/app/config
  - ${PD_ZURG_DOWNLOADS_PATH:-${STORAGE_PATH}/Zurg/downloads}:/downloads  
  - ${STORAGE_PATH}/Zurg:/data:shared  # ✅ FUSE mount point

# Added FUSE capabilities:
cap_add:
  - SYS_ADMIN
devices:
  - /dev/fuse:/dev/fuse
security_opt:
  - apparmor:unconfined
```

### **CineSync Service - Fixed Source/Destination**
```yaml
environment:
  # ✅ Now uses Zurg's __all__ folder
  - SOURCE_DIR=${CINESYNC_SOURCE_DIR:-${STORAGE_PATH}/Zurg/__all__}
  # ✅ Outputs to media folder for Plex
  - DESTINATION_DIR=${CINESYNC_DESTINATION_DIR:-${STORAGE_PATH}/media}

volumes:
  - ${STORAGE_PATH}/Zurg:/zurg:ro  # ✅ Access to Zurg files
```

### **Plex Service - Fixed Media Paths**
```yaml
volumes:
  # ✅ Now uses correct media paths  
  - ${STORAGE_PATH}/media/movies:/data/movies
  - ${STORAGE_PATH}/media/tv:/data/tv
```

## 🌐 **Environment Variables Added**

Updated `.env` file with proper paths:
```bash
# ZURG CONFIGURATION
ZURG_PORT=9999
PD_ZURG_DOWNLOADS_PATH=${STORAGE_PATH}/Zurg

# CINESYNC CONFIGURATION  
CINESYNC_SOURCE_DIR=${STORAGE_PATH}/Zurg/__all__
CINESYNC_DESTINATION_DIR=${STORAGE_PATH}/media
```

## 🎯 **Benefits of This Configuration**

### ✅ **Fully Dynamic Paths**
- All paths use `${STORAGE_PATH}` variable
- Users can set any storage path they want
- No hardcoded paths anywhere

### ✅ **Proper Zurg Integration**  
- CineSync reads from Zurg's `__all__` folder
- Gets all Real Debrid content automatically
- Virtual files processed correctly

### ✅ **Clean Organization**
- CineSync organizes content into proper structure
- Plex libraries match CineSync output folders
- Anime content properly separated

### ✅ **Scalable Architecture**
- Easy to add new media types
- Consistent path structure across all services
- Environment-based configuration

## 🚀 **Complete Integration Flow**

```
Real Debrid → Zurg → CineSync → Plex
     ↓           ↓        ↓        ↓
API Content → Virtual → Organized → Libraries
             Files     Folders
```

1. **Zurg** creates virtual files from Real Debrid at `${STORAGE_PATH}/Zurg/__all__/`
2. **CineSync** reads from `__all__` and organizes to `${STORAGE_PATH}/media/`
3. **Plex** scans organized media folders and creates libraries
4. **Users** get perfectly organized, automatically populated media libraries

## 🧪 **Testing the Configuration**

After restart, verify paths:
```bash
# Check Zurg virtual files
ls ${STORAGE_PATH}/Zurg/__all__/

# Check CineSync organized output  
ls ${STORAGE_PATH}/media/

# Check Plex can see the media
docker exec surge-plex ls /data/movies
```

**Result**: Complete end-to-end media flow with no hardcoded paths! 🎉
