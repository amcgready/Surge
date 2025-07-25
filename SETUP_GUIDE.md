# Surge Setup & Command-Line Access Guide

## 🚀 **First-Time Setup**

Surge now includes an interactive setup wizard that configures everything for you!

### **Option 1: Automated Setup (Recommended)**
```bash
git clone https://github.com/amcgready/Surge.git
cd Surge
./surge setup    # Interactive setup wizard
```

The setup wizard will ask you:
- ✅ **Media server choice** (Plex, Jellyfin, or Emby)
- ✅ **Storage location** (where to store media and configs)
- ✅ **User/Group IDs** (for proper file permissions)
- ✅ **Timezone** (for scheduling)
- ✅ **Optional services** (Bazarr, NZBGet, etc.)
- ✅ **Automation preferences** (auto-updates, scheduling)

After setup, simply run:
```bash
./surge deploy <your-chosen-media-server>
```

### **Option 2: Manual Setup**
```bash
git clone https://github.com/amcgready/Surge.git
cd Surge
cp .env.example .env
# Edit .env with your preferences
./surge deploy plex
```

---

## 🖥️ **Command-Line Tool Access**

### **Scanly Commands**

Scanly is your advanced media scanner. Access it with:

```bash
# Quick scan of your media
./surge exec scanly scan

# Organize files according to your rules
./surge exec scanly organize

# Configure Scanly settings
./surge exec scanly config

# Interactive shell for advanced usage
./surge exec scanly shell

# Custom commands (equivalent to running python3 main.py in the container)
./surge exec scanly "python3 main.py --help"
./surge exec scanly "python3 main.py --scan --path /movies"
```

### **Kometa Commands**

Manage metadata and collections:

```bash
# Run full Kometa process
./surge exec kometa "--run"

# Run specific library
./surge exec kometa "--run --library Movies"

# Test configuration
./surge exec kometa "--run --test"

# Interactive shell
./surge exec kometa shell
```

### **Service Shell Access**

Get shell access to any running service:

```bash
./surge exec radarr      # Access Radarr container
./surge exec sonarr      # Access Sonarr container
./surge exec plex        # Access Plex container
./surge exec nzbget      # Access NZBGet container
```

---

## 📋 **What Happens During Setup**

### **1. Configuration Generation**
- Creates `.env` file with your preferences
- Sets up proper user/group IDs for file permissions
- Configures network ports and service options

### **2. Directory Structure Creation**
```
/opt/surge/                    # Your chosen storage location
├── media/
│   ├── movies/               # Movie files
│   ├── tv/                   # TV show files
│   └── music/                # Music files
├── downloads/                # Download client output
├── config/                   # Service configurations
└── logs/                     # Processing logs
```

### **3. Service Configuration Templates**
- Kometa configuration with your media server details
- Homepage dashboard configuration
- Service integration settings

### **4. Permission Setup**
- Ensures all directories have correct ownership
- Sets up proper user/group mappings for containers

---

## 🔧 **Post-Setup Configuration**

### **1. Media Server Setup**

**Plex:**
1. Visit http://localhost:32400/web
2. Sign in with your Plex account
3. Add libraries pointing to `/data/movies` and `/data/tv`

**Jellyfin/Emby:**
1. Visit http://localhost:8096
2. Complete setup wizard
3. Add libraries pointing to `/data/movies` and `/data/tv`

### **2. Download Client Configuration**

**NZBGet:**
1. Visit http://localhost:6789
2. Login: `admin` / `tegbzn6789`
3. Configure your Usenet providers

### **3. Automation Setup**

**Radarr:**
1. Visit http://localhost:7878
2. Add root folder: `/movies`
3. Configure download clients and indexers

**Sonarr:**
1. Visit http://localhost:8989
2. Add root folder: `/tv`
3. Configure download clients and indexers

### **4. API Keys & Integration**

Get API keys for enhanced functionality:
- **TMDB API**: https://www.themoviedb.org/settings/api
- **Trakt** (optional): https://trakt.tv/oauth/applications

Add them to your `.env` file:
```bash
TMDB_API_KEY=your_key_here
```

---

## 🎯 **Common Use Cases**

### **Daily Operations**
```bash
# Check everything is running
./surge status

# Run a media scan
./surge exec scanly scan

# Process assets manually
./surge process sequence

# View recent logs
./surge logs
```

### **Maintenance**
```bash
# Update all containers
./surge update

# Restart everything
./surge restart

# Clean up Docker system
./surge cleanup
```

### **Troubleshooting**
```bash
# View specific service logs
./surge logs radarr

# Reset problematic service
./surge reset plex

# Access service for debugging
./surge exec plex
```

---

## 🔄 **Automated vs Manual Operations**

### **Automated (Runs Daily at 2 AM)**
- ✅ **ImageMaid** → **Posterizarr** → **Kometa** sequence
- ✅ **Container updates** (if enabled)
- ✅ **Media scanning** (if configured)

### **Manual (Run When Needed)**
- 🖱️ **Scanly operations**: `./surge exec scanly scan`
- 🖱️ **Asset processing**: `./surge process sequence`
- 🖱️ **Service management**: `./surge restart`

---

## ✅ **Setup Complete!**

After running `./surge setup` and `./surge deploy`, you have:

1. ✅ **Complete media stack** running and integrated
2. ✅ **Command-line access** to all tools via `./surge exec`
3. ✅ **Automatic scheduling** for asset processing
4. ✅ **Shared assets** across all services
5. ✅ **Web interfaces** for all services
6. ✅ **Unified dashboard** at http://localhost:3000

**Your one-stop media management solution is ready to go!** 🎬🚀
