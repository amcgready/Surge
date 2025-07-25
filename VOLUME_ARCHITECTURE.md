# Surge Volume Architecture

## Current Volume Structure

### 🔄 **SHARED Between All Services:**

#### Media Files (Most Important!)
```
movies/          # ✅ All services read/write
tv/              # ✅ All services read/write  
music/           # ✅ All services read/write
downloads/       # ✅ All download clients write here
```

#### Assets & Metadata  
```
shared-assets/   # ✅ Kometa, Posterizarr, ImageMaid, Media Servers
├── posters/
├── backgrounds/
├── collections/
└── metadata/

shared-logs/     # ✅ All processing logs
```

### 🔒 **SEPARATE Per Service:**

#### Service Configurations
```
radarr-config/      # ❌ Only Radarr
sonarr-config/      # ❌ Only Sonarr  
plex-config/        # ❌ Only Plex
bazarr-config/      # ❌ Only Bazarr
kometa-config/      # ❌ Only Kometa
posterizarr-config/ # ❌ Only Posterizarr
...etc
```

## 🤔 **The Key Question:**

**Should service configs also be shared?**

### Option A: Keep Current (Recommended)
- ✅ Share media files and assets (what matters for integration)  
- 🔒 Keep service configs separate (security & stability)

### Option B: Share Everything
- ✅ Share ALL volumes including service configurations
- ⚠️ Potential conflicts and security concerns

## 📊 **What's Actually Important to Share:**

### ✅ **MUST Share (Already Done):**
1. **Media Files** - All services need access to movies/tv
2. **Assets Folder** - Posters, artwork, metadata
3. **Downloads** - Where content arrives

### ❓ **Optional to Share:**
1. **Service Configs** - Settings, databases, API keys
2. **Logs** - Currently shared for processing services

---

## 🎯 **Current Status:**

**✅ The important stuff IS shared:**
- Movies, TV, Music files
- Assets (posters, artwork) 
- Download directory
- Processing logs

**🔒 Service configs are separate for good reasons:**
- Radarr can't mess up Sonarr's settings
- Plex database stays isolated
- Easier troubleshooting
- Better security

## 💭 **Your Choice:**

Would you prefer:
1. **Keep current** (share media/assets, separate configs) ✅ Recommended
2. **Share everything** (including service configs) ⚠️ Possible but risky
