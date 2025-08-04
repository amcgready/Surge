# ✅ Perfect Path Configuration - Zurg → CineSync → Plex

## 🎯 **Final Correct Path Structure**

### **🗂️ Directory Flow:**
```
${STORAGE_PATH}/downloads/
├── Zurg/                           # Zurg downloads root
│   ├── __all__/                    # Zurg's all content folder ← CineSync SOURCE
│   │   ├── movies/                 # Virtual movie files
│   │   ├── shows/                  # Virtual TV show files  
│   │   └── anime/                  # Virtual anime files
│   ├── movies/                     # Individual organized folders
│   ├── shows/
│   └── anime/
└── CineSync/                       # CineSync output ← Plex SOURCE
    ├── movies/                     # Organized movies → Plex Movies library
    ├── tv/                         # Organized TV shows → Plex TV library
    ├── movies/anime/               # Organized anime movies → Plex Anime Movies
    └── tv/anime/                   # Organized anime series → Plex Anime Series
```

## 🔄 **Data Flow:**

```
Real Debrid → Zurg → CineSync → Plex
             ↓        ↓         ↓
          Virtual → Organized → Libraries
           Files    Structure
```

1. **Zurg** creates virtual files at `${STORAGE_PATH}/downloads/Zurg/__all__/`
2. **CineSync** reads from `__all__` and organizes to `${STORAGE_PATH}/downloads/CineSync/`
3. **Plex** scans organized CineSync folders and creates libraries

## ⚙️ **Service Configurations:**

### **Zurg Service**
```yaml
volumes:
  - ${STORAGE_PATH}/Zurg/config:/app/config
  - ${STORAGE_PATH}/downloads/Zurg:/data:shared  # FUSE mount point
```
- **Creates virtual files**: `${STORAGE_PATH}/downloads/Zurg/__all__/`
- **FUSE enabled**: Can create virtual filesystem
- **Shared mount**: CineSync can access files

### **CineSync Service** 
```yaml
environment:
  - SOURCE_DIR=${STORAGE_PATH}/downloads/Zurg/__all__   # Reads from Zurg
  - DESTINATION_DIR=${STORAGE_PATH}/downloads/CineSync  # Outputs organized files
volumes:
  - ${STORAGE_PATH}/downloads:/downloads                # Access to both folders
```

### **Plex Service**
```yaml
volumes:
  - ${STORAGE_PATH}/downloads/CineSync/movies:/data/movies
  - ${STORAGE_PATH}/downloads/CineSync/tv:/data/tv
```
- **Scans organized content**: From CineSync output
- **Creates libraries**: Movies, TV Shows, Anime Movies, Anime Series

## 🌐 **Environment Variables:**

Updated `.env` with correct paths:
```bash
# CINESYNC CONFIGURATION  
CINESYNC_SOURCE_DIR=${STORAGE_PATH}/downloads/Zurg/__all__
CINESYNC_DESTINATION_DIR=${STORAGE_PATH}/downloads/CineSync
```

## 📚 **Plex Library Paths:**

The automated Plex library creation now uses:
```python
cinesync_folders = {
    'Movies': '/data/movies',           # → ${STORAGE_PATH}/downloads/CineSync/movies
    'TV Shows': '/data/tv',             # → ${STORAGE_PATH}/downloads/CineSync/tv  
    'Anime Movies': '/data/movies/anime', # → ${STORAGE_PATH}/downloads/CineSync/movies/anime
    'Anime Series': '/data/tv/anime'    # → ${STORAGE_PATH}/downloads/CineSync/tv/anime
}
```

## ✅ **Benefits of This Structure:**

### **🎯 Clean Organization**
- All downloads under `${STORAGE_PATH}/downloads/`
- Clear separation: `Zurg/` vs `CineSync/`
- Logical flow: Raw → Organized

### **📁 User-Friendly Paths**
- `STORAGE_PATH=/home/user/media` → Everything under `/home/user/media/downloads/`
- `STORAGE_PATH=/mnt/nas/surge` → Everything under `/mnt/nas/surge/downloads/`
- No hardcoded paths anywhere

### **🔄 Perfect Integration**
- Zurg provides content via `__all__` folder
- CineSync organizes content automatically  
- Plex scans organized structure
- Libraries auto-populate with proper metadata

### **🚀 Scalable Architecture**
- Easy to add new content types
- Clear data flow and responsibilities
- Environment-based configuration
- Works with any storage path

## 🧪 **Testing the Setup:**

```bash
# 1. Check Zurg creates __all__ folder
ls ${STORAGE_PATH}/downloads/Zurg/__all__/

# 2. Check CineSync organizes content  
ls ${STORAGE_PATH}/downloads/CineSync/

# 3. Check Plex can see organized media
docker exec surge-plex ls /data/movies
docker exec surge-plex ls /data/tv

# 4. Verify library paths in Plex
# Should show: Movies, TV Shows, Anime Movies, Anime Series
```

**Perfect! Now Zurg downloads to the right place, CineSync reads from `__all__`, and Plex gets perfectly organized libraries! 🎉**
