# Plex Library Automation for Surge

## Overview

Surge now includes **automatic Plex library creation** based on your CineSync folder structure. When you deploy Surge with Plex as your media server, the system will automatically:

1. **Configure your Plex server name** (customizable in the setup UI)
2. **Create four organized libraries** matching CineSync's structure:
   - **Movies** (`/media/movies`) - Regular movies
   - **TV Shows** (`/media/tv`) - Regular TV series
   - **Anime Movies** (`/media/movies/anime`) - Anime films
   - **Anime Series** (`/media/tv/anime`) - Anime TV shows

## Features

### ✨ Zero Manual Setup
- No need to manually create libraries in Plex
- Automatic metadata agent assignment (TMDB for movies, TVDB for shows)
- Proper library paths matching your CineSync organization

### 🎯 Smart Organization
- Works seamlessly with CineSync's folder structure
- Separates anime content from regular content
- Maintains clean, organized media libraries

### 🚀 WebUI Integration
- Configure server name directly in the setup wizard
- Visual confirmation of library creation plan
- One-click deployment with full automation

## How It Works

### 1. WebUI Configuration
When setting up Surge through the WebUI:

1. **Select Plex** as your media server in Step 1
2. **Configure server name** in the expanded Plex settings
3. **Review library creation plan** shown in the UI
4. **Deploy** - libraries are created automatically after services start

### 2. Automatic Library Creation
During deployment:

```bash
# The system automatically runs:
python3 scripts/configure-plex-libraries.py \
  --server-name "Your Server Name" \
  --storage-path /opt/surge
```

### 3. Result
Your Plex server will have:
- **Updated server name** (as configured)
- **Four ready-to-use libraries** with proper agents
- **Paths matching CineSync structure** for seamless integration

## Manual Usage

### Test Connection Only
```bash
python3 scripts/configure-plex-libraries.py --test-only
```

### Create Libraries with Custom Settings
```bash
python3 scripts/configure-plex-libraries.py \
  --server-name "My Custom Server Name" \
  --storage-path /path/to/storage \
  --plex-url http://localhost:32400
```

### Run Test Script
```bash
./scripts/test-plex-libraries.sh
```

## Library Structure

The automation creates libraries with these paths:

| Library Name   | Path                    | Type    | Content                    |
|----------------|-------------------------|---------|----------------------------|
| Movies         | `/media/movies`         | movie   | Regular movies             |
| TV Shows       | `/media/tv`             | show    | Regular TV series          |
| Anime Movies   | `/media/movies/anime`   | movie   | Anime films                |
| Anime Series   | `/media/tv/anime`       | show    | Anime TV shows             |

## Integration Points

### Backend Integration
- **File**: `WebUI/backend/app.py` (lines 983+)
- **Trigger**: Runs after API discovery during deployment
- **Condition**: Only when Plex is selected as media server

### Frontend Integration
- **File**: `WebUI/frontend/src/App.js`
- **Location**: Media Server selection step (Step 1)
- **Features**: Server name configuration, library creation preview

### Core Script
- **File**: `scripts/configure-plex-libraries.py`
- **Purpose**: Handles Plex API communication and library creation
- **Features**: Connection testing, server naming, library management

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Verify Plex is running: `docker ps | grep plex`
   - Check Plex URL is accessible
   - Ensure Plex token is available

2. **Libraries Not Created**
   - Check Plex token permissions
   - Verify storage paths exist
   - Review deployment logs for errors

3. **Wrong Library Paths**
   - Confirm CineSync configuration
   - Check storage path mapping
   - Verify Docker volume mounts

### Manual Verification

1. Access Plex at `http://localhost:32400/web`
2. Verify server name matches your configuration
3. Check all 4 libraries are present in sidebar
4. Confirm library paths point to correct folders

## Environment Variables

The script respects these environment variables:

- `PLEX_TOKEN` - Plex authentication token
- `DATA_ROOT` - Override storage path
- `CINESYNC_CUSTOM_*_FOLDER` - Custom folder mappings

## Benefits

### For Users
- **Immediate usability** - Plex ready with organized libraries
- **Consistent setup** - Same structure across all deployments
- **Time saving** - No manual library configuration needed

### For Automation
- **CineSync integration** - Perfect match with folder organization
- **Scalable** - Easy to add more libraries in the future
- **Maintainable** - Centralized configuration and setup

## Future Enhancements

Potential improvements for future versions:

- **Custom library names** - Allow user-defined library names
- **Additional categories** - Support for music, photos, etc.
- **Advanced metadata** - Custom metadata agent configurations
- **Bulk operations** - Update existing libraries, mass reorganization
- **Multi-server** - Support for multiple Plex servers

---

This automation makes Surge the fastest way to get from zero to a fully configured media server with organized libraries!
