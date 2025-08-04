# Zurg Configuration Implementation Summary

## Files Created/Modified

### 1. New Configuration Template
- **File**: `configs/zurg-config.yml.template`
- **Purpose**: Complete Zurg configuration template with all settings from upstream
- **Features**:
  - Real-Debrid token placeholder
  - Complete directory structure (anime, shows, movies)
  - Proper filtering rules and group ordering
  - Plex library update integration
  - Auto-repair and RAR deletion settings

### 2. Plex Update Script Template
- **File**: `configs/plex_update.sh.template`
- **Purpose**: Script for Zurg to trigger Plex library updates
- **Features**:
  - Automatic Plex library refresh on content changes
  - Logging of update events
  - Environment variable configuration

### 3. Updated Setup Scripts

#### shared-config.sh
- **Added**: `update_zurg_config()` function
- **Features**:
  - Creates Zurg config from template
  - Replaces RD_API_TOKEN placeholder
  - Adjusts for different media servers (Plex/Jellyfin/Emby)
  - Copies Plex update script with proper permissions
- **Integration**: Added to configuration propagation workflow

#### first-time-setup.sh
- **Added**: Zurg to service directory creation
- **Added**: ENABLE_ZURG configuration option
- **Added**: User prompt for Zurg enablement
- **Added**: RD_API_TOKEN validation for Zurg
- **Added**: Zurg to homepage configuration
- **Added**: Zurg to access information displays
- **Added**: ZURG_PORT definition (9999)

### 4. Docker Configuration Updates

#### docker-compose.yml
- **Added**: Port mapping for Zurg (9999:9999)
- **Added**: Profile for Zurg service
- **Uses**: `${ZURG_PORT:-9999}` environment variable

## Configuration Details

### Required Settings Now Configured:
1. **Real-Debrid Integration**: Token automatically inserted
2. **Directory Structure**: Complete anime/shows/movies configuration
3. **Library Updates**: Plex integration with update script
4. **Performance Settings**: 
   - `check_for_changes_every_secs: 10`
   - `enable_repair: true`
   - `auto_delete_rar_torrents: true`
5. **Content Filtering**: Regex patterns for proper categorization

### Setup Process:
1. User is prompted to enable Zurg during setup
2. If enabled, RD_API_TOKEN is required
3. Configuration template is copied and customized
4. Plex update script is installed
5. Service directories are created
6. Homepage integration is configured

### Access Information:
- **Web Interface**: http://localhost:9999
- **Configuration**: `${STORAGE_PATH}/Zurg/config/config.yml`
- **Downloads**: `${ZURG_DOWNLOADS_PATH:-${STORAGE_PATH}/Zurg/downloads/}`
- **Update Logs**: `${STORAGE_PATH}/Zurg/config/plex_updates.log`

## Download Destination Configuration

### **Default Setup:**
- **Container Path**: `/downloads` (inside Zurg container)
- **Host Path**: `${STORAGE_PATH}/Zurg/downloads` (default)
- **Customizable**: Yes, via `ZURG_DOWNLOADS_PATH` environment variable

### **How to Change Destination:**

#### **Method 1: Environment Variable**
Set `ZURG_DOWNLOADS_PATH` in your `.env` file:
```bash
ZURG_DOWNLOADS_PATH=/custom/path/to/zurg/downloads
```

#### **Method 2: During Setup**
The setup wizard now prompts for a custom Zurg downloads path when Zurg is enabled.

#### **Method 3: Direct Edit**
Modify the docker-compose.yml volume mapping:
```yaml
volumes:
  - ${ZURG_DOWNLOADS_PATH:-${STORAGE_PATH}/Zurg/downloads}:/downloads
```

### **Integration Notes:**
- **CineSync**: Automatically uses Zurg downloads as source when configured
- **Media Servers**: Can access Zurg downloads through standard volume mappings
- **Permissions**: Uses PUID/PGID for proper file ownership

## Compatibility

This implementation ensures compatibility with:
- **Media Servers**: Plex (default), Jellyfin, Emby
- **Real-Debrid**: Full API integration
- **Surge Workflow**: Integrated with existing setup process
- **Docker Profiles**: Can be enabled/disabled via profiles

## Benefits

1. **Complete Setup**: All Zurg settings from upstream configuration
2. **Automatic Configuration**: No manual file editing required
3. **Token Management**: Secure RD_API_TOKEN handling
4. **Media Server Integration**: Automatic library updates
5. **User-Friendly**: Integrated into Surge setup wizard
6. **Maintainable**: Template-based approach for easy updates
