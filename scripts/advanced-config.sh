#!/bin/bash

# ===========================================
# SURGE ADVANCED CONFIGURATION MANAGER
# ===========================================
# This script provides advanced configuration options
# for all Surge services through an interactive CLI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SURGE_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment and utilities
if [ -f "$SURGE_ROOT/.env" ]; then
    set -a
    source "$SURGE_ROOT/.env"
    set +a
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Helper functions
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_header() { echo -e "\n${CYAN}🔧 $1${NC}\n"; }

show_help() {
    echo "Surge Advanced Configuration Manager"
    echo ""
    echo "Usage: ./surge advanced [COMMAND] [SERVICE]"
    echo ""
    echo "Commands:"
    echo "  config [service]        - Configure advanced options for a service"
    echo "  list                    - List all services with advanced options"
    echo "  backup                  - Backup current advanced configurations"
    echo "  restore                 - Restore advanced configurations from backup"
    echo "  reset [service]         - Reset service to default advanced settings"
    echo "  validate [service]      - Validate advanced configuration"
    echo "  export [service]        - Export advanced config to JSON"
    echo "  import [service] [file] - Import advanced config from JSON"
    echo ""
    echo "Services with Advanced Configuration:"
    echo "  prowlarr               - Indexer management advanced settings"
    echo "  radarr                 - Movie management advanced options"
    echo "  sonarr                 - TV show management advanced options"
    echo "  bazarr                 - Subtitle management advanced settings"
    echo "  placeholdarr           - Placeholder management advanced options"
    echo "  overseerr              - Request management advanced settings"
    echo "  tautulli               - Analytics and monitoring advanced options"
    echo "  nzbget                 - Download client advanced configuration"
    echo "  rdt-client             - Real-Debrid client advanced settings"
    echo "  zurg                   - Mount and streaming advanced options"
    echo "  decypharr              - Decryption service advanced settings"
    echo "  kometa                 - Metadata management advanced options"
    echo "  posterizarr            - Poster management advanced settings"
    echo "  scanly                 - Media scanning advanced configuration"
    echo "  cinesync               - Library synchronization advanced options"
    echo "  imagemaid              - Image processing advanced settings"
    echo "  gaps                   - Collection gap analysis advanced options"
    echo "  cli-debrid             - CLI debrid tool advanced settings"
    echo "  homepage               - Dashboard advanced customization"
    echo ""
    echo "Examples:"
    echo "  ./surge advanced config prowlarr       # Configure Prowlarr advanced options"
    echo "  ./surge advanced list                  # List all services"
    echo "  ./surge advanced backup               # Backup all advanced configs"
    echo "  ./surge advanced validate placeholdarr # Validate Placeholdarr config"
    echo ""
}

# List all services with advanced configuration options
list_services() {
    print_header "Services with Advanced Configuration Options"
    
    local services=(
        "plex:Plex Media Server configuration"
        "prowlarr:Indexer management and automation"
        "radarr:Movie collection management"
        "sonarr:TV series management"
        "bazarr:Subtitle downloading and management"
        "placeholdarr:Placeholder file management"
        "overseerr:Media request management"
        "tautulli:Plex analytics and monitoring"
        "nzbget:Usenet download client"
        "rdt-client:Real-Debrid integration"
        "zurg:Real-Debrid mounting service"
        "decypharr:Decryption and processing"
        "kometa:Metadata and collection management"
        "posterizarr:Poster and artwork management"
        "scanly:Media library scanning"
        "cinesync:Library synchronization"
        "imagemaid:Image optimization"
        "gaps:Collection gap analysis"
        "cli-debrid:CLI debrid tools"
        "homepage:Dashboard customization"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service desc <<< "$service_info"
        enabled_var="ENABLE_${service^^}"
        enabled_var="${enabled_var//-/_}"
        enabled="${!enabled_var:-false}"
        
        if [[ "$enabled" == "true" ]]; then
            echo -e "  ${GREEN}✅${NC} ${CYAN}$service${NC} - $desc"
        else
            echo -e "  ${YELLOW}⚪${NC} ${CYAN}$service${NC} - $desc (disabled)"
        fi
    done
    
    echo ""
    print_info "Use './surge advanced config <service>' to configure a specific service"
}

# Configure advanced options for a specific service
configure_service() {
    local service="$1"
    
    case "$service" in
        plex)
            configure_plex_advanced
            ;;
        prowlarr)
            configure_prowlarr_advanced
            ;;
        radarr)
            configure_radarr_advanced
            ;;
        sonarr)
            configure_sonarr_advanced
            ;;
        bazarr)
            configure_bazarr_advanced
            ;;
        placeholdarr)
            configure_placeholdarr_advanced
            ;;
        overseerr)
            configure_overseerr_advanced
            ;;
        tautulli)
            configure_tautulli_advanced
            ;;
        nzbget)
            configure_nzbget_advanced
            ;;
        rdt-client)
            configure_rdt_client_advanced
            ;;
        zurg)
            configure_zurg_advanced
            ;;
        decypharr)
            configure_decypharr_advanced
            ;;
        kometa)
            configure_kometa_advanced
            ;;
        posterizarr)
            configure_posterizarr_advanced
            ;;
        scanly)
            configure_scanly_advanced
            ;;
        cinesync)
            configure_cinesync_advanced
            ;;
        imagemaid)
            configure_imagemaid_advanced
            ;;
        gaps)
            configure_gaps_advanced
            ;;
        cli-debrid)
            configure_cli_debrid_advanced
            ;;
        homepage)
            configure_homepage_advanced
            ;;
        *)
            print_error "Unknown service: $service"
            print_info "Run './surge advanced list' to see available services"
            exit 1
            ;;
    esac
}

# Plex Advanced Configuration
configure_plex_advanced() {
    print_header "Plex Media Server Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/plex"
    local prefs_file="$config_dir/Library/Application Support/Plex Media Server/Preferences.xml"
    
    print_info "Configuring advanced Plex settings..."
    
    echo "1. Server Settings"
    echo "   Current server name: ${PLEX_SERVER_NAME:-SurgePlex}"
    read -p "   Server name [${PLEX_SERVER_NAME:-SurgePlex}]: " server_name
    server_name=${server_name:-${PLEX_SERVER_NAME:-SurgePlex}}
    read -p "   Plex Claim Token (for first setup): " claim_token
    read -p "   Manual port mapping [32400]: " manual_port
    read -p "   Enable HTTPS [true]: " enable_https
    read -p "   Secure connections (disabled/preferred/required) [preferred]: " secure_connections
    
    echo ""
    echo "2. Transcoding Settings"
    read -p "   Enable hardware transcoding [true]: " hw_transcoding
    read -p "   Use hardware decode [true]: " hw_decode
    read -p "   Transcoder quality (0-3, 3=automatic) [3]: " transcoder_quality
    read -p "   Transcoder temp directory [/transcode]: " transcoder_temp
    read -p "   Background transcoding x264 preset [veryfast]: " x264_preset
    
    echo ""
    echo "3. Library Settings"
    read -p "   Generate BIF (preview thumbnails) [true]: " generate_bif
    read -p "   Generate chapter thumbnails [true]: " chapter_thumbnails
    read -p "   Scan my library automatically [true]: " auto_scan
    read -p "   Run a partial scan when changes are detected [true]: " partial_scan
    read -p "   Include music libraries in automatic scans [true]: " music_auto_scan
    
    echo ""
    echo "4. Network Settings"
    read -p "   Enable DLNA server [true]: " enable_dlna
    read -p "   Enable Bonjour/Avahi [true]: " enable_bonjour
    read -p "   Treat WAN IP as LAN [false]: " treat_wan_as_lan
    read -p "   List of IP addresses and networks that are allowed without auth: " lan_networks
    read -p "   Custom server access URLs (comma-separated): " custom_connections
    
    echo ""
    echo "5. Remote Access"
    read -p "   Enable remote access [true]: " remote_access
    read -p "   Manually specify public port [false]: " manual_public_port
    if [[ "${manual_public_port:-false}" == "true" ]]; then
        read -p "   Public port: " public_port
    fi
    read -p "   Enable relay [true]: " enable_relay
    
    echo ""
    echo "6. Metadata Settings"
    read -p "   Enable metadata download [true]: " metadata_download
    read -p "   Include IMDB tags [true]: " imdb_tags
    read -p "   Store track tags as genres [false]: " track_tags_as_genres
    read -p "   Prefer local metadata [false]: " prefer_local_metadata
    read -p "   Language for metadata [English]: " metadata_language
    
    echo ""
    echo "7. Performance and Maintenance"
    read -p "   Log level (ERROR/WARN/INFO/DEBUG) [INFO]: " log_level
    read -p "   Enable analytics [true]: " enable_analytics
    read -p "   Send crash reports [true]: " crash_reports
    read -p "   Background task interval [daily]: " bg_task_interval
    read -p "   Vacuum database on startup [false]: " vacuum_on_startup
    
    # Create Plex preferences configuration
    mkdir -p "$(dirname "$prefs_file")"
    
    cat > "$config_dir/advanced-preferences.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<!-- Plex Advanced Configuration -->
<!-- Generated by Surge Advanced Config Manager -->
<Preferences 
    FriendlyName="${server_name:-SurgePlex}"
    PlexClaimToken="${claim_token}"
    ManualPortMappingPort="${manual_port:-32400}"
    secureConnections="${secure_connections:-1}"
    enableHttps="${enable_https:-1}"
    
    TranscoderVideoResolutionLimit="${transcoder_quality:-3}"
    TranscoderTempDirectory="${transcoder_temp:-/transcode}"
    TranscoderVideoEncodeH264PresetAuto="${x264_preset:-veryfast}"
    HardwareAcceleratedCodecs="${hw_transcoding:-1}"
    TranscoderVideoDecodingHardwareVideoCodec="${hw_decode:-1}"
    
    GenerateBIFBehavior="${generate_bif:-asap}"
    GenerateChapterThumb="${chapter_thumbnails:-1}"
    ScanAtStartup="${auto_scan:-1}"
    RefreshLibrariesOnStart="${partial_scan:-1}"
    MusicScanAtStartup="${music_auto_scan:-1}"
    
    DlnaEnabled="${enable_dlna:-1}"
    DlnaBrowseAudio="${enable_dlna:-1}"
    EnableBonjourAdvertisement="${enable_bonjour:-1}"
    TreatWanIpAsLocal="${treat_wan_as_lan:-0}"
    LanNetworks="${lan_networks}"
    customConnections="${custom_connections}"
    
    PublishServerOnPlexOnlineKey="${remote_access:-1}"
    manualPortMappingMode="${manual_public_port:-0}"$([ "${manual_public_port:-false}" = "true" ] && [ -n "${public_port}" ] && echo "
    ManualPortMappingPort=\"${public_port}\"" || echo "")
    RelayEnabled="${enable_relay:-1}"
    
    EnableMetadataDownload="${metadata_download:-1}"
    IncludeImdbTags="${imdb_tags:-1}"
    StoreTrackTagsAsGenres="${track_tags_as_genres:-0}"
    PreferLocalMetadata="${prefer_local_metadata:-0}"
    MetadataLanguage="${metadata_language:-en}"
    
    logLevel="${log_level:-2}"
    EnableSyncAnalytics="${enable_analytics:-1}"
    EnableCrashReporting="${crash_reports:-1}"
    ScheduledLibraryUpdatesInterval="${bg_task_interval:-43200}"
    VacuumDbOnStartup="${vacuum_on_startup:-0}"
/>
EOF

    # Create a preferences deployment script
    cat > "$config_dir/apply-advanced-preferences.sh" << 'EOF'
#!/bin/bash
# Script to apply advanced Plex preferences
# Run this after Plex container is started

PLEX_CONFIG_DIR="${STORAGE_PATH:-/opt/surge}/config/plex"
PREFS_FILE="$PLEX_CONFIG_DIR/Library/Application Support/Plex Media Server/Preferences.xml"
ADVANCED_FILE="$PLEX_CONFIG_DIR/advanced-preferences.xml"

if [ -f "$ADVANCED_FILE" ] && [ -f "$PREFS_FILE" ]; then
    echo "Merging advanced preferences with existing Plex preferences..."
    # Backup original preferences
    cp "$PREFS_FILE" "$PREFS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Copy advanced preferences
    cp "$ADVANCED_FILE" "$PREFS_FILE"
    
    echo "Advanced preferences applied. Restart Plex container to take effect."
elif [ -f "$ADVANCED_FILE" ]; then
    echo "No existing preferences found. Copying advanced preferences..."
    mkdir -p "$(dirname "$PREFS_FILE")"
    cp "$ADVANCED_FILE" "$PREFS_FILE"
    echo "Advanced preferences applied."
else
    echo "No advanced preferences file found. Run advanced configuration first."
fi
EOF
    
    chmod +x "$config_dir/apply-advanced-preferences.sh"

    # Update PLEX_SERVER_NAME in .env file if it was changed
    if [[ "$server_name" != "$(grep '^PLEX_SERVER_NAME=' "$ENV_FILE" 2>/dev/null | cut -d'=' -f2)" ]]; then
        print_info "Updating PLEX_SERVER_NAME in environment configuration..."
        if grep -q "^PLEX_SERVER_NAME=" "$ENV_FILE" 2>/dev/null; then
            sed -i "s/^PLEX_SERVER_NAME=.*/PLEX_SERVER_NAME=$server_name/" "$ENV_FILE"
        else
            echo "PLEX_SERVER_NAME=$server_name" >> "$ENV_FILE"
        fi
        print_warning "Plex container restart required for server name change to take effect"
    fi

    print_success "Plex advanced configuration saved to $config_dir/advanced-preferences.xml"
    print_info "Run $config_dir/apply-advanced-preferences.sh after Plex starts to apply settings"
    print_info "Or restart Plex to apply changes: docker-compose restart plex"
}

# Prowlarr Advanced Configuration
configure_prowlarr_advanced() {
    print_header "Prowlarr Advanced Configuration"
    
    local config_file="${STORAGE_PATH:-/opt/surge}/config/prowlarr/config.xml"
    
    print_info "Configuring advanced Prowlarr settings..."
    
    echo "1. API and Authentication Settings"
    read -p "   API Rate Limit (requests/minute) [60]: " api_rate_limit
    read -p "   Enable API Key Authentication [true]: " enable_api_auth
    read -p "   Authentication Method (Basic/Forms) [Basic]: " auth_method
    
    echo ""
    echo "2. Indexer Management"
    read -p "   Auto-sync with *arr apps interval (minutes) [15]: " sync_interval
    read -p "   Maximum concurrent searches [10]: " max_searches
    read -p "   Search timeout (seconds) [30]: " search_timeout
    
    echo ""
    echo "3. Proxy and Network Settings"
    read -p "   Use proxy for indexers [false]: " use_proxy
    if [[ "${use_proxy:-false}" == "true" ]]; then
        read -p "   Proxy type (HTTP/SOCKS5) [HTTP]: " proxy_type
        read -p "   Proxy hostname: " proxy_host
        read -p "   Proxy port: " proxy_port
        read -p "   Proxy username (optional): " proxy_user
        read -s -p "   Proxy password (optional): " proxy_pass
        echo ""
    fi
    
    echo ""
    echo "4. Logging and Monitoring"
    read -p "   Log Level (Trace/Debug/Info/Warn/Error) [Info]: " log_level
    read -p "   Enable analytics [true]: " enable_analytics
    read -p "   Log retention days [7]: " log_retention
    
    # Apply configuration
    mkdir -p "$(dirname "$config_file")"
    
    cat > "${config_file}.advanced" << EOF
# Prowlarr Advanced Configuration
# Generated by Surge Advanced Config Manager

<Config>
  <!-- API Settings -->
  <ApiRateLimit>${api_rate_limit:-60}</ApiRateLimit>
  <EnableApiAuth>${enable_api_auth:-true}</EnableApiAuth>
  <AuthenticationMethod>${auth_method:-Basic}</AuthenticationMethod>
  
  <!-- Indexer Management -->
  <SyncInterval>${sync_interval:-15}</SyncInterval>
  <MaxConcurrentSearches>${max_searches:-10}</MaxConcurrentSearches>
  <SearchTimeout>${search_timeout:-30}</SearchTimeout>
  
  <!-- Proxy Settings -->
  <UseProxy>${use_proxy:-false}</UseProxy>
EOF

    if [[ "${use_proxy:-false}" == "true" ]]; then
        cat >> "${config_file}.advanced" << EOF
  <ProxyType>${proxy_type:-HTTP}</ProxyType>
  <ProxyHostname>${proxy_host}</ProxyHostname>
  <ProxyPort>${proxy_port}</ProxyPort>
  <ProxyUsername>${proxy_user}</ProxyUsername>
  <ProxyPassword>${proxy_pass}</ProxyPassword>
EOF
    fi
    
    cat >> "${config_file}.advanced" << EOF
  
  <!-- Logging -->
  <LogLevel>${log_level:-Info}</LogLevel>
  <EnableAnalytics>${enable_analytics:-true}</EnableAnalytics>
  <LogRetentionDays>${log_retention:-7}</LogRetentionDays>
</Config>
EOF

    print_success "Prowlarr advanced configuration saved to ${config_file}.advanced"
    print_info "Restart Prowlarr to apply changes: docker-compose restart prowlarr"
}

# Placeholdarr Advanced Configuration
configure_placeholdarr_advanced() {
    print_header "Placeholdarr Advanced Configuration"
    
    local config_file="${STORAGE_PATH:-/opt/surge}/config/placeholdarr/config.yml"
    
    print_info "Configuring advanced Placeholdarr settings..."
    
    echo "1. Plex Integration"
    read -p "   Plex URL [http://plex:32400]: " plex_url
    read -p "   Plex Token: " plex_token
    read -p "   Update Plex libraries after changes [true]: " update_plex
    
    echo ""
    echo "2. Library Paths"
    read -p "   Movie library folder [/data/media/Movies]: " movie_folder
    read -p "   TV library folder [/data/media/TV]: " tv_folder
    read -p "   Dummy file path [/data/media/placeholder.mkv]: " dummy_file
    
    echo ""
    echo "3. Placeholder Strategy"
    echo "   Available strategies: hardlink, copy, symlink"
    read -p "   Placeholder strategy [hardlink]: " placeholder_strategy
    read -p "   Coming soon dummy file [/data/media/comingsoon.mkv]: " coming_soon_file
    
    echo ""
    echo "4. Monitoring and Timing"
    read -p "   Check interval (minutes) [30]: " check_interval
    read -p "   Calendar lookahead days [14]: " calendar_days
    read -p "   Calendar sync interval hours [6]: " calendar_sync
    read -p "   Available cleanup delay hours [2]: " cleanup_delay
    
    echo ""
    echo "5. TV Show Settings"
    echo "   TV Play modes: episode, season"
    read -p "   TV play mode [episode]: " tv_play_mode
    read -p "   Include specials [false]: " include_specials
    read -p "   Episodes lookahead [3]: " episodes_lookahead
    
    echo ""
    echo "6. Coming Soon Features"
    read -p "   Enable coming soon placeholders [true]: " enable_coming_soon
    read -p "   Enable coming soon countdown [false]: " enable_countdown
    read -p "   Preferred movie date type (inCinemas/physicalRelease) [inCinemas]: " date_type
    
    echo ""
    echo "7. Advanced Options"
    read -p "   Title updates (OFF/UPDATE/CREATE) [OFF]: " title_updates
    read -p "   Max monitor time hours [72]: " max_monitor_time
    read -p "   Log level (Trace/Debug/Info/Warn/Error) [Info]: " log_level
    read -p "   API key [surgestack]: " api_key
    
    # Create configuration
    mkdir -p "$(dirname "$config_file")"
    
    cat > "$config_file" << EOF
# Placeholdarr Advanced Configuration
# Generated by Surge Advanced Config Manager

# Plex Configuration
plex:
  url: ${plex_url:-http://plex:32400}
  token: ${plex_token}
  update_libraries: ${update_plex:-true}

# Service Connections
radarr:
  url: http://radarr:7878
  api_key: \${RADARR_API_KEY}
  
sonarr:
  url: http://sonarr:8989
  api_key: \${SONARR_API_KEY}

# Library Configuration
libraries:
  movies: ${movie_folder:-/data/media/Movies}
  tv: ${tv_folder:-/data/media/TV}
  dummy_file: ${dummy_file:-/data/media/placeholder.mkv}
  coming_soon_file: ${coming_soon_file:-/data/media/comingsoon.mkv}

# Placeholder Settings
placeholder:
  strategy: ${placeholder_strategy:-hardlink}
  tv_play_mode: ${tv_play_mode:-episode}
  include_specials: ${include_specials:-false}
  title_updates: ${title_updates:-OFF}

# Monitoring Configuration  
monitoring:
  check_interval_minutes: ${check_interval:-30}
  max_monitor_time_hours: ${max_monitor_time:-72}
  available_cleanup_delay_hours: ${cleanup_delay:-2}

# Calendar Settings
calendar:
  lookahead_days: ${calendar_days:-14}
  sync_interval_hours: ${calendar_sync:-6}
  placeholder_mode: episode

# Coming Soon Features
coming_soon:
  enabled: ${enable_coming_soon:-true}
  countdown_enabled: ${enable_countdown:-false}
  preferred_date_type: ${date_type:-inCinemas}
  episodes_lookahead: ${episodes_lookahead:-3}

# System Settings
system:
  api_key: ${api_key:-surgestack}
  auth_method: Basic
  log_level: ${log_level:-Info}
  launch_browser: false
  branch: master
EOF

    print_success "Placeholdarr advanced configuration saved to $config_file"
    print_info "Restart Placeholdarr to apply changes: docker-compose restart placeholdarr"
}

# Backup current advanced configurations
backup_configs() {
    print_header "Backing Up Advanced Configurations"
    
    local backup_dir="${STORAGE_PATH:-$SURGE_ROOT/data}/config/backups/advanced-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    local services=(
        "prowlarr"
        "radarr" 
        "sonarr"
        "bazarr"
        "placeholdarr"
        "overseerr"
        "tautulli"
        "nzbget"
        "rdt-client"
        "zurg"
        "decypharr"
        "kometa"
        "posterizarr"
        "scanly"
        "cinesync"
        "imagemaid"
        "gaps"
        "homepage"
    )
    
    for service in "${services[@]}"; do
        local config_path="${STORAGE_PATH:-$SURGE_ROOT/data}/config/$service"
        if [ -d "$config_path" ]; then
            print_info "Backing up $service configuration..."
            cp -r "$config_path" "$backup_dir/$service" 2>/dev/null || true
        fi
    done
    
    # Create backup manifest
    cat > "$backup_dir/manifest.json" << EOF
{
  "backup_date": "$(date -Iseconds)",
  "surge_version": "$(git -C "$SURGE_ROOT" describe --tags 2>/dev/null || echo "unknown")",
  "services_backed_up": [
$(printf '    "%s",\n' "${services[@]}" | head -n -1)
$(printf '    "%s"\n' "${services[-1]}")
  ]
}
EOF
    
    print_success "Advanced configurations backed up to: $backup_dir"
}

# Validate advanced configuration for a service
validate_config() {
    local service="$1"
    print_header "Validating $service Advanced Configuration"
    
    local config_path="${STORAGE_PATH:-$SURGE_ROOT/data}/config/$service"
    
    if [ ! -d "$config_path" ]; then
        print_error "Configuration directory not found: $config_path"
        return 1
    fi
    
    case "$service" in
        placeholdarr)
            validate_placeholdarr_config "$config_path"
            ;;
        prowlarr)
            validate_prowlarr_config "$config_path"
            ;;
        *)
            print_warning "Validation not implemented for $service yet"
            ;;
    esac
}

validate_placeholdarr_config() {
    local config_path="$1"
    local config_file="$config_path/config.yml"
    
    if [ ! -f "$config_file" ]; then
        print_error "Configuration file not found: $config_file"
        return 1
    fi
    
    # Check YAML syntax
    if command -v yq >/dev/null 2>&1; then
        if yq eval '.' "$config_file" >/dev/null 2>&1; then
            print_success "YAML syntax is valid"
        else
            print_error "YAML syntax is invalid"
            return 1
        fi
    else
        print_warning "yq not available, skipping YAML validation"
    fi
    
    # Check required fields
    local required_fields=("plex.url" "radarr.url" "sonarr.url" "libraries.movies" "libraries.tv")
    
    for field in "${required_fields[@]}"; do
        if grep -q "$field" "$config_file"; then
            print_success "Required field '$field' is present"
        else
            print_warning "Required field '$field' is missing"
        fi
    done
    
    print_success "Placeholdarr configuration validation completed"
}

# Radarr Advanced Configuration
configure_radarr_advanced() {
    print_header "Radarr Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/radarr"
    
    print_info "Configuring advanced Radarr settings..."
    
    echo "1. Quality and Media Management"
    read -p "   Minimum movie age before download (days) [0]: " min_age
    read -p "   Maximum movie file size (GB) [50]: " max_size
    read -p "   Delete failed downloads [true]: " delete_failed
    read -p "   Skip free space check [false]: " skip_free_space
    
    echo ""
    echo "2. Metadata and Naming"
    read -p "   Rename movies [true]: " rename_movies
    read -p "   Replace illegal characters [true]: " replace_illegal
    read -p "   Create movie folders [true]: " create_folders
    read -p "   Movie naming format [{Movie Title} ({Release Year})]: " naming_format
    
    echo ""
    echo "3. Import Settings"
    read -p "   Copy/hardlink files [Hardlink]: " copy_method
    read -p "   Import extra files (subs, nfo) [true]: " import_extra
    read -p "   Skip file size check [false]: " skip_size_check
    read -p "   Rescan after refresh [Always]: " rescan_mode
    
    echo ""
    echo "4. Advanced Network Settings"
    read -p "   Connection limit per indexer [60]: " connection_limit
    read -p "   Enable SSL certificate validation [true]: " ssl_validation
    read -p "   Request timeout (seconds) [100]: " request_timeout
    
    echo ""
    echo "5. Monitoring and Lists"
    read -p "   Monitor new movies [true]: " monitor_new
    read -p "   Availability delay (days) [0]: " availability_delay
    read -p "   RSS sync interval (minutes) [15]: " rss_interval
    
    # Create advanced settings JSON
    mkdir -p "$config_dir"
    
    cat > "$config_dir/advanced-settings.json" << EOF
{
  "mediaManagement": {
    "minimumAge": ${min_age:-0},
    "maximumSize": ${max_size:-50},
    "deleteFailedDownloads": ${delete_failed:-true},
    "skipFreeSpaceCheck": ${skip_free_space:-false},
    "renameMovies": ${rename_movies:-true},
    "replaceIllegalCharacters": ${replace_illegal:-true},
    "createMovieFolders": ${create_folders:-true},
    "movieNamingFormat": "${naming_format:-{Movie Title} ({Release Year})}",
    "copyMethod": "${copy_method:-Hardlink}",
    "importExtraFiles": ${import_extra:-true},
    "skipFileSizeCheck": ${skip_size_check:-false},
    "rescanAfterRefresh": "${rescan_mode:-Always}"
  },
  "networking": {
    "connectionLimit": ${connection_limit:-60},
    "sslCertificateValidation": ${ssl_validation:-true},
    "requestTimeout": ${request_timeout:-100}
  },
  "monitoring": {
    "monitorNewMovies": ${monitor_new:-true},
    "availabilityDelay": ${availability_delay:-0},
    "rssSyncInterval": ${rss_interval:-15}
  }
}
EOF

    print_success "Radarr advanced configuration saved to $config_dir/advanced-settings.json"
    print_info "Restart Radarr to apply changes: docker-compose restart radarr"
}

# Sonarr Advanced Configuration
configure_sonarr_advanced() {
    print_header "Sonarr Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/sonarr"
    
    print_info "Configuring advanced Sonarr settings..."
    
    echo "1. Episode Management"
    read -p "   Skip episodes with no air date [false]: " skip_no_air_date
    read -p "   Delete empty folders [true]: " delete_empty
    read -p "   Season folder format [Season %s]: " season_format
    read -p "   Series naming format [{Series Title}]: " series_format
    
    echo ""
    echo "2. Quality and Import Settings"
    read -p "   Unpack archives [true]: " unpack_archives
    read -p "   Ignore deleted episodes [false]: " ignore_deleted
    read -p "   Allow episode reprocessing [true]: " allow_reprocess
    read -p "   Auto-unmonitor deleted episodes [false]: " auto_unmonitor
    
    echo ""
    echo "3. Calendar and Monitoring"
    read -p "   Calendar start day (Sunday/Monday) [Sunday]: " calendar_start
    read -p "   First day of week (0=Sunday, 1=Monday) [0]: " first_day
    read -p "   Short date format [MMM d yyyy]: " short_date_format
    read -p "   Long date format [dddd, MMMM d yyyy]: " long_date_format
    read -p "   Time format [h(:mm)tt]: " time_format
    
    echo ""
    echo "4. RSS and Searching"
    read -p "   RSS sync interval (minutes) [15]: " rss_sync_interval
    read -p "   Maximum automatic search age (days) [7]: " max_search_age
    read -p "   Retention days [0]: " retention_days
    
    echo ""
    echo "5. Advanced Options"
    read -p "   Enable color-impaired mode [false]: " color_impaired
    read -p "   Show relative dates [true]: " show_relative_dates
    read -p "   Enable SSL for API calls [false]: " enable_ssl_api
    
    # Create advanced settings JSON
    mkdir -p "$config_dir"
    
    cat > "$config_dir/advanced-settings.json" << EOF
{
  "episodeManagement": {
    "skipEpisodesWithoutAirDate": ${skip_no_air_date:-false},
    "deleteEmptyFolders": ${delete_empty:-true},
    "seasonFolderFormat": "${season_format:-Season %s}",
    "seriesNamingFormat": "${series_format:-{Series Title}}",
    "unpackArchives": ${unpack_archives:-true},
    "ignoreDeletedEpisodes": ${ignore_deleted:-false},
    "allowEpisodeReprocessing": ${allow_reprocess:-true},
    "autoUnmonitorDeletedEpisodes": ${auto_unmonitor:-false}
  },
  "calendar": {
    "calendarWeekStartDay": "${calendar_start:-Sunday}",
    "firstDayOfWeek": ${first_day:-0},
    "shortDateFormat": "${short_date_format:-MMM d yyyy}",
    "longDateFormat": "${long_date_format:-dddd, MMMM d yyyy}",
    "timeFormat": "${time_format:-h(:mm)tt}"
  },
  "rssAndSearch": {
    "rssSyncInterval": ${rss_sync_interval:-15},
    "maximumAutomaticSearchAge": ${max_search_age:-7},
    "retentionDays": ${retention_days:-0}
  },
  "advanced": {
    "colorImpairedMode": ${color_impaired:-false},
    "showRelativeDates": ${show_relative_dates:-true},
    "enableSslForApiCalls": ${enable_ssl_api:-false}
  }
}
EOF

    print_success "Sonarr advanced configuration saved to $config_dir/advanced-settings.json"
    print_info "Restart Sonarr to apply changes: docker-compose restart sonarr"
}

# Bazarr Advanced Configuration
configure_bazarr_advanced() {
    print_header "Bazarr Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/bazarr"
    
    print_info "Configuring advanced Bazarr settings..."
    
    echo "1. Subtitle Search Settings"
    read -p "   Minimum score for movies (0-100) [70]: " min_score_movie
    read -p "   Minimum score for series (0-100) [70]: " min_score_series
    read -p "   Use embedded subtitles [true]: " use_embedded
    read -p "   Use hearing impaired subtitles [false]: " hearing_impaired
    
    echo ""
    echo "2. Providers and Languages"
    read -p "   Max subtitle providers to query [5]: " max_providers
    read -p "   Provider timeout (seconds) [30]: " provider_timeout
    read -p "   Enable anti-captcha [false]: " anti_captcha
    read -p "   Provider rate limit (req/hour) [100]: " rate_limit
    
    echo ""
    echo "3. Post-Processing"
    read -p "   Use post-processing [false]: " use_postprocessing
    read -p "   Post-processing command: " postprocess_cmd
    read -p "   Use chmod on files [false]: " use_chmod
    read -p "   File permissions (e.g. 644): " file_permissions
    
    echo ""
    echo "4. Synchronization"
    read -p "   Sync subtitles [false]: " sync_subtitles
    read -p "   Subtitle sync threshold (seconds) [2.0]: " sync_threshold
    read -p "   Maximum offset (seconds) [60]: " max_offset
    read -p "   Use subsync [false]: " use_subsync
    
    echo ""
    echo "5. Advanced Options"
    read -p "   Debug mode [false]: " debug_mode
    read -p "   Upgrade manual searches [true]: " upgrade_manual
    read -p "   Skip video scan on import [false]: " skip_video_scan
    
    # Create configuration INI file
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.ini.advanced" << EOF
[general]
# Subtitle Search Settings
movie_minimum_score = ${min_score_movie:-70}
series_minimum_score = ${min_score_series:-70}
use_embedded_subs = ${use_embedded:-True}
hearing_impaired = ${hearing_impaired:-False}

# Provider Settings
maximum_providers = ${max_providers:-5}
provider_timeout = ${provider_timeout:-30}
anti_captcha_enabled = ${anti_captcha:-False}
provider_rate_limit = ${rate_limit:-100}

# Post-Processing
use_postprocessing = ${use_postprocessing:-False}
postprocessing_cmd = ${postprocess_cmd}
chmod_enabled = ${use_chmod:-False}
file_permission = ${file_permissions:-644}

# Synchronization
sync_subtitles = ${sync_subtitles:-False}
sync_threshold = ${sync_threshold:-2.0}
maximum_offset = ${max_offset:-60}
use_subsync = ${use_subsync:-False}

# Advanced
debug = ${debug_mode:-False}
upgrade_manual = ${upgrade_manual:-True}
skip_video_scan = ${skip_video_scan:-False}

[radarr]
enabled = True
url = http://radarr:7878
api_key = \${RADARR_API_KEY}

[sonarr]  
enabled = True
url = http://sonarr:8989
api_key = \${SONARR_API_KEY}
EOF

    print_success "Bazarr advanced configuration saved to $config_dir/config.ini.advanced"
    print_info "Merge with existing config.ini or restart Bazarr: docker-compose restart bazarr"
}

configure_overseerr_advanced() {
    print_header "Overseerr Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/overseerr"
    
    print_info "Configuring advanced Overseerr settings..."
    
    echo "1. Request Management"
    read -p "   Default movie request retention (days) [14]: " movie_retention
    read -p "   Default TV request retention (days) [14]: " tv_retention
    read -p "   Auto-approve movie requests [false]: " auto_approve_movies
    read -p "   Auto-approve TV requests [false]: " auto_approve_tv
    read -p "   Max requests per user per day [5]: " max_requests_day
    
    echo ""
    echo "2. Quality Profiles"
    read -p "   Default movie quality profile ID [1]: " movie_quality_id
    read -p "   Default TV quality profile ID [1]: " tv_quality_id
    read -p "   Default movie root folder: " movie_root_folder
    read -p "   Default TV root folder: " tv_root_folder
    
    echo ""
    echo "3. Notification Settings"
    read -p "   Enable Discord notifications [true]: " discord_enabled
    read -p "   Discord webhook URL: " discord_webhook
    read -p "   Enable email notifications [false]: " email_enabled
    read -p "   SMTP server (if email enabled): " smtp_server
    read -p "   SMTP port [587]: " smtp_port
    
    echo ""
    echo "4. Integration Settings"
    read -p "   Enable Plex integration [true]: " plex_integration
    read -p "   Auto-scan Plex libraries [true]: " plex_auto_scan
    read -p "   Enable Tautulli integration [true]: " tautulli_integration
    read -p "   Trust proxy headers [false]: " trust_proxy
    
    echo ""
    echo "5. Advanced Options"
    read -p "   Enable CSRF protection [true]: " csrf_protection
    read -p "   Application title [Surge Overseerr]: " app_title
    read -p "   Hide available media [false]: " hide_available
    read -p "   Default locale [en]: " default_locale
    
    # Create advanced settings JSON
    mkdir -p "$config_dir"
    
    cat > "$config_dir/advanced-settings.json" << EOF
{
  "requestManagement": {
    "movieRetentionDays": ${movie_retention:-14},
    "tvRetentionDays": ${tv_retention:-14},
    "autoApproveMovies": ${auto_approve_movies:-false},
    "autoApproveTv": ${auto_approve_tv:-false},
    "maxRequestsPerUserPerDay": ${max_requests_day:-5}
  },
  "qualityProfiles": {
    "defaultMovieQualityProfile": ${movie_quality_id:-1},
    "defaultTvQualityProfile": ${tv_quality_id:-1},
    "defaultMovieRootFolder": "${movie_root_folder}",
    "defaultTvRootFolder": "${tv_root_folder}"
  },
  "notifications": {
    "discord": {
      "enabled": ${discord_enabled:-true},
      "webhookUrl": "${discord_webhook}"
    },
    "email": {
      "enabled": ${email_enabled:-false},
      "smtpServer": "${smtp_server}",
      "smtpPort": ${smtp_port:-587}
    }
  },
  "integrations": {
    "plex": {
      "enabled": ${plex_integration:-true},
      "autoScan": ${plex_auto_scan:-true}
    },
    "tautulli": {
      "enabled": ${tautulli_integration:-true}
    }
  },
  "advanced": {
    "csrfProtection": ${csrf_protection:-true},
    "applicationTitle": "${app_title:-Surge Overseerr}",
    "hideAvailable": ${hide_available:-false},
    "defaultLocale": "${default_locale:-en}",
    "trustProxy": ${trust_proxy:-false}
  }
}
EOF

    print_success "Overseerr advanced configuration saved to $config_dir/advanced-settings.json"
    print_info "Apply settings through Overseerr web interface or restart: docker-compose restart overseerr"
}

configure_tautulli_advanced() {
    print_warning "Tautulli advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_nzbget_advanced() {
    print_header "NZBGet Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/nzbget"
    
    print_info "Configuring advanced NZBGet settings..."
    
    echo "1. Download Settings"
    read -p "   Download speed limit (KB/s, 0=unlimited) [0]: " speed_limit
    read -p "   Article timeout (seconds) [60]: " article_timeout
    read -p "   URL timeout (seconds) [60]: " url_timeout
    read -p "   Max retry connections [3]: " max_connections
    read -p "   Retry interval (seconds) [10]: " retry_interval
    
    echo ""
    echo "2. Server Settings"
    read -p "   Server thread limit [100]: " thread_limit
    read -p "   Download queue size (MB) [1000]: " queue_size
    read -p "   Write buffer (KB) [1024]: " write_buffer
    read -p "   Flush queue (MB) [200]: " flush_queue
    
    echo ""
    echo "3. Security and Network"
    read -p "   Use secure connections (TLS) [true]: " use_tls
    read -p "   Certificate verification [true]: " cert_verify
    read -p "   Control IP (0.0.0.0 for all) [0.0.0.0]: " control_ip
    read -p "   Username for web interface [${NZBGET_USER:-admin}]: " web_username
    read -s -p "   Password for web interface: " web_password
    echo ""
    
    echo ""
    echo "4. Post-processing"
    read -p "   Unpack downloaded archives [true]: " unpack
    read -p "   Duplicate check [true]: " duplicate_check
    read -p "   Cleanup disk space [true]: " cleanup_disk
    read -p "   Par repair [true]: " par_repair
    read -p "   Par threads [1]: " par_threads
    
    echo ""
    echo "5. Logging and Monitoring"
    read -p "   Log level (ERROR/WARNING/INFO/DETAIL/DEBUG) [INFO]: " log_level
    read -p "   Rotate logs [true]: " rotate_logs
    read -p "   Error target (log/screen/both) [log]: " error_target
    read -p "   Debug target (log/screen/both) [log]: " debug_target
    
    # Create NZBGet configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/advanced-settings.conf" << EOF
# NZBGet Advanced Configuration
# Generated by Surge Advanced Config Manager

# Download Settings
DownloadRate=${speed_limit:-0}
ArticleTimeout=${article_timeout:-60}
UrlTimeout=${url_timeout:-60}
RetryInterval=${retry_interval:-10}
MaxConnectionsPerServer=${max_connections:-3}

# Server Settings
ServerThreads=${thread_limit:-100}
WriteBuffer=${write_buffer:-1024}
FlushQueue=${flush_queue:-200}

# Security and Network
SecureControl=${use_tls:-yes}
CertVerification=${cert_verify:-yes}
ControlIP=${control_ip:-0.0.0.0}
ControlUsername=${web_username:-${NZBGET_USER:-admin}}
ControlPassword=${web_password}

# Post-processing
Unpack=${unpack:-yes}
DirectUnpack=yes
DupeCheck=${duplicate_check:-yes}
CleanupDisk=${cleanup_disk:-yes}
ParRepair=${par_repair:-yes}
ParThreads=${par_threads:-1}

# Logging
LogLevel=${log_level:-INFO}
RotateLog=${rotate_logs:-yes}
ErrorTarget=${error_target:-log}
DebugTarget=${debug_target:-log}

# Performance
DownloadQueueSize=${queue_size:-1000}
ArticleCache=200
DirectWrite=yes
CrcCheck=yes
FileNaming=nzb
ReloadQueue=yes
ContinuePartial=yes

# Categories
Category1.Name=Movies
Category1.DestDir=downloads/Movies
Category1.Extensions=
Category1.Priority=0

Category2.Name=TV
Category2.DestDir=downloads/TV
Category2.Extensions=
Category2.Priority=0

Category3.Name=Music
Category3.DestDir=downloads/Music
Category3.Extensions=
Category3.Priority=0

Category4.Name=Books
Category4.DestDir=downloads/Books
Category4.Extensions=
Category4.Priority=0
EOF

    print_success "NZBGet advanced configuration saved to $config_dir/advanced-settings.conf"
    print_info "Copy contents to NZBGet web interface Settings > Advanced or restart NZBGet"
}

configure_rdt_client_advanced() {
    print_header "RDT-Client Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/rdt-client"
    
    print_info "Configuring advanced RDT-Client settings..."
    
    echo "1. Real-Debrid Configuration"
    read -p "   Real-Debrid API Token: " rd_token
    read -p "   Check torrent status interval (seconds) [30]: " status_interval
    read -p "   Max concurrent downloads [5]: " max_downloads
    read -p "   Download timeout (minutes) [60]: " download_timeout
    
    echo ""
    echo "2. Download Management"
    read -p "   Download path [/data/downloads]: " download_path
    read -p "   Auto-delete completed torrents [false]: " auto_delete
    read -p "   Minimum seeders required [1]: " min_seeders
    read -p "   Minimum file size (MB) [1]: " min_file_size
    read -p "   Maximum file size (GB) [20]: " max_file_size
    
    echo ""
    echo "3. Quality Filtering"
    read -p "   Allowed video formats (comma-separated) [mp4,mkv,avi]: " video_formats
    read -p "   Preferred quality [1080p]: " preferred_quality
    read -p "   Block cam/ts releases [true]: " block_cam
    read -p "   Require proper releases [false]: " require_proper
    
    echo ""
    echo "4. Connection Settings"
    read -p "   Connection timeout (seconds) [30]: " conn_timeout
    read -p "   Retry attempts [3]: " retry_attempts
    read -p "   User Agent [RDT-Client/1.0]: " user_agent
    read -p "   Enable proxy [false]: " enable_proxy
    if [[ "${enable_proxy:-false}" == "true" ]]; then
        read -p "   Proxy URL: " proxy_url
    fi
    
    echo ""
    echo "5. Logging and Monitoring"
    read -p "   Log level (DEBUG/INFO/WARNING/ERROR) [INFO]: " log_level
    read -p "   Enable download history [true]: " enable_history
    read -p "   History retention days [30]: " history_retention
    read -p "   Enable notifications [false]: " enable_notifications
    
    # Create RDT-Client configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/advanced-config.json" << EOF
{
  "realDebrid": {
    "apiToken": "${rd_token}",
    "statusCheckInterval": ${status_interval:-30},
    "maxConcurrentDownloads": ${max_downloads:-5},
    "downloadTimeout": ${download_timeout:-60}
  },
  "downloads": {
    "downloadPath": "${download_path:-/data/downloads}",
    "autoDeleteCompleted": ${auto_delete:-false},
    "minimumSeeders": ${min_seeders:-1},
    "minimumFileSize": ${min_file_size:-1},
    "maximumFileSize": ${max_file_size:-20000}
  },
  "quality": {
    "allowedFormats": "${video_formats:-mp4,mkv,avi}".split(","),
    "preferredQuality": "${preferred_quality:-1080p}",
    "blockCamTS": ${block_cam:-true},
    "requireProper": ${require_proper:-false}
  },
  "connection": {
    "timeout": ${conn_timeout:-30},
    "retryAttempts": ${retry_attempts:-3},
    "userAgent": "${user_agent:-RDT-Client/1.0}",
    "enableProxy": ${enable_proxy:-false}$([ "${enable_proxy:-false}" = "true" ] && echo ",
    \"proxyUrl\": \"${proxy_url}\"" || echo "")
  },
  "logging": {
    "level": "${log_level:-INFO}",
    "enableHistory": ${enable_history:-true},
    "historyRetentionDays": ${history_retention:-30},
    "enableNotifications": ${enable_notifications:-false}
  },
  "categories": {
    "movies": {
      "path": "/data/downloads/movies",
      "minQuality": "720p",
      "maxSize": 8000
    },
    "tv": {
      "path": "/data/downloads/tv", 
      "minQuality": "720p",
      "maxSize": 4000
    }
  }
}
EOF

    print_success "RDT-Client advanced configuration saved to $config_dir/advanced-config.json"
    print_info "Restart RDT-Client to apply changes: docker-compose restart rdt-client"
}

configure_zurg_advanced() {
    print_header "Zurg Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/zurg"
    local config_file="$config_dir/config.yml"
    
    print_info "Configuring advanced Zurg settings..."
    
    echo "1. Real-Debrid Integration"
    read -p "   Real-Debrid API Token: " rd_token
    read -p "   Enable torrent processing [true]: " enable_torrents
    read -p "   Torrent selection timeout (seconds) [30]: " torrent_timeout
    read -p "   Max concurrent downloads [5]: " max_downloads
    
    echo ""
    echo "2. Mount and Network Settings"
    read -p "   Mount directory [/data/zurg]: " mount_dir
    read -p "   Enable network mode [true]: " network_mode
    read -p "   Network interface (optional): " network_interface
    read -p "   Mount options [allow_other,default_permissions]: " mount_options
    
    echo ""
    echo "3. Cache and Performance"
    read -p "   Enable file caching [true]: " enable_cache
    read -p "   Cache size (MB) [1024]: " cache_size
    read -p "   Cache expiry (hours) [24]: " cache_expiry
    read -p "   Prefetch size (MB) [100]: " prefetch_size
    read -p "   Max open files [1000]: " max_open_files
    
    echo ""
    echo "4. Logging and Monitoring"
    read -p "   Log level (debug/info/warn/error) [info]: " log_level
    read -p "   Enable access logging [false]: " access_logging
    read -p "   Enable metrics [true]: " enable_metrics
    read -p "   Metrics port [9999]: " metrics_port
    
    echo ""
    echo "5. Advanced Features"
    read -p "   Enable auto-retry [true]: " auto_retry
    read -p "   Retry attempts [3]: " retry_attempts
    read -p "   Retry delay (seconds) [5]: " retry_delay
    read -p "   Enable compression [false]: " enable_compression
    
    # Create Zurg configuration
    mkdir -p "$config_dir"
    
    cat > "$config_file" << EOF
# Zurg Advanced Configuration
# Generated by Surge Advanced Config Manager

# Real-Debrid Configuration
realdebrid:
  api_token: "${rd_token}"
  enable_torrents: ${enable_torrents:-true}
  torrent_timeout: ${torrent_timeout:-30}
  max_downloads: ${max_downloads:-5}

# Mount Configuration  
mount:
  dir: "${mount_dir:-/data/zurg}"
  network_mode: ${network_mode:-true}
  network_interface: "${network_interface}"
  options: "${mount_options:-allow_other,default_permissions}"

# Cache Settings
cache:
  enabled: ${enable_cache:-true}
  size_mb: ${cache_size:-1024}
  expiry_hours: ${cache_expiry:-24}
  prefetch_mb: ${prefetch_size:-100}

# Performance
performance:
  max_open_files: ${max_open_files:-1000}
  
# Logging
logging:
  level: "${log_level:-info}"
  access_log: ${access_logging:-false}
  
# Monitoring
monitoring:
  metrics_enabled: ${enable_metrics:-true}
  metrics_port: ${metrics_port:-9999}

# Advanced Settings
advanced:
  auto_retry: ${auto_retry:-true}
  retry_attempts: ${retry_attempts:-3}
  retry_delay_seconds: ${retry_delay:-5}
  compression_enabled: ${enable_compression:-false}

# Server Configuration
server:
  host: "::"
  port: 9999
  plex_update:
    enabled: true
    libraries:
      - name: "Movies"
        path: "/data/media/Movies"
      - name: "TV Shows"  
        path: "/data/media/TV"
EOF

    print_success "Zurg advanced configuration saved to $config_file"
    print_info "Restart Zurg to apply changes: docker-compose restart zurg"
}

configure_decypharr_advanced() {
    print_header "Decypharr Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/decypharr"
    
    print_info "Configuring advanced Decypharr settings..."
    
    echo "1. Debrid Service Configuration"
    read -p "   Primary debrid service (realdebrid/alldebrid/premiumize) [realdebrid]: " primary_service
    read -p "   Real-Debrid API Token: " rd_token
    read -p "   AllDebrid API Token (optional): " ad_token
    read -p "   Premiumize API Token (optional): " pm_token
    
    echo ""
    echo "2. Download Client Settings"
    read -p "   Download client type (qbittorrent/deluge/transmission) [qbittorrent]: " client_type
    read -p "   Client host [localhost]: " client_host
    read -p "   Client port [8080]: " client_port
    read -p "   Client username [admin]: " client_username
    read -s -p "   Client password: " client_password
    echo ""
    
    echo ""
    echo "3. Processing Settings"
    read -p "   Check interval (seconds) [60]: " check_interval
    read -p "   Max concurrent downloads [5]: " max_concurrent
    read -p "   Auto-delete completed torrents [false]: " auto_delete
    read -p "   Minimum file size (MB) [100]: " min_size
    read -p "   Maximum file size (GB) [50]: " max_size
    
    echo ""
    echo "4. Quality and Filtering"
    read -p "   Preferred video codecs (h264,h265,x264,x265) [h264,h265]: " video_codecs
    read -p "   Preferred audio codecs (aac,ac3,dts,flac) [aac,ac3]: " audio_codecs
    read -p "   Block keywords (comma-separated): " block_keywords
    read -p "   Require keywords (comma-separated): " require_keywords
    
    echo ""
    echo "5. Paths and Organization"
    read -p "   Movies download path [/mnt/movies]: " movies_path
    read -p "   TV shows download path [/mnt/tv]: " tv_path
    read -p "   Temp download path [/tmp/downloads]: " temp_path
    read -p "   Create subdirectories [true]: " create_subdirs
    
    echo ""
    echo "6. Logging and Monitoring"
    read -p "   Log level (DEBUG/INFO/WARNING/ERROR) [INFO]: " log_level
    read -p "   Enable webhooks [false]: " enable_webhooks
    if [[ "${enable_webhooks:-false}" == "true" ]]; then
        read -p "   Webhook URL: " webhook_url
    fi
    
    # Create Decypharr configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.yml" << EOF
# Decypharr Advanced Configuration
# Generated by Surge Advanced Config Manager

debrid_services:
  primary: "${primary_service:-realdebrid}"
  
  real_debrid:
    api_token: "${rd_token}"
    enabled: true
    
  all_debrid:
    api_token: "${ad_token}"
    enabled: $([ -n "${ad_token}" ] && echo "true" || echo "false")
    
  premiumize:
    api_token: "${pm_token}" 
    enabled: $([ -n "${pm_token}" ] && echo "true" || echo "false")

download_client:
  type: "${client_type:-qbittorrent}"
  host: "${client_host:-localhost}"
  port: ${client_port:-8080}
  username: "${client_username:-admin}"
  password: "${client_password}"
  
processing:
  check_interval: ${check_interval:-60}
  max_concurrent: ${max_concurrent:-5}
  auto_delete_completed: ${auto_delete:-false}
  min_file_size_mb: ${min_size:-100}
  max_file_size_gb: ${max_size:-50}

quality:
  preferred_video_codecs: [$(echo "${video_codecs:-h264,h265}" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')] 
  preferred_audio_codecs: [$(echo "${audio_codecs:-aac,ac3}" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')] 
  block_keywords: [$(echo "${block_keywords}" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')] 
  require_keywords: [$(echo "${require_keywords}" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')] 

paths:
  movies: "${movies_path:-/mnt/movies}"
  tv: "${tv_path:-/mnt/tv}"
  temp: "${temp_path:-/tmp/downloads}"
  create_subdirectories: ${create_subdirs:-true}

logging:
  level: "${log_level:-INFO}"
  
notifications:
  webhooks:
    enabled: ${enable_webhooks:-false}$([ "${enable_webhooks:-false}" = "true" ] && echo "
    url: \"${webhook_url}\"" || echo "")

# Service Integration
integrations:
  radarr:
    enabled: true
    url: "http://radarr:7878"
    category: "movies"
    
  sonarr:
    enabled: true
    url: "http://sonarr:8989"
    category: "tv"
EOF

    print_success "Decypharr advanced configuration saved to $config_dir/config.yml"
    print_info "Restart Decypharr to apply changes: docker-compose restart decypharr"
}

configure_kometa_advanced() {
    print_header "Kometa Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/kometa"
    
    print_info "Configuring advanced Kometa settings..."
    
    echo "1. Plex Server Configuration"
    read -p "   Plex URL [http://plex:32400]: " plex_url
    read -p "   Plex Token: " plex_token
    read -p "   Plex timeout (seconds) [60]: " plex_timeout
    read -p "   Clean bundles [false]: " clean_bundles
    read -p "   Empty trash [false]: " empty_trash
    
    echo ""
    echo "2. TMDb Configuration"
    read -p "   TMDb API Key: " tmdb_key
    read -p "   TMDb language [en]: " tmdb_language
    read -p "   TMDb cache expiration (days) [60]: " tmdb_cache_expiry
    
    echo ""
    echo "3. Collection Settings"
    read -p "   Create collections [true]: " create_collections
    read -p "   Collection minimum items [2]: " collection_minimum
    read -p "   Delete below minimum [false]: " delete_below_minimum
    read -p "   Missing only released [false]: " missing_only_released
    read -p "   Only filter missing [false]: " only_filter_missing
    
    echo ""
    echo "4. Image Settings"
    read -p "   Asset directory [/config/assets]: " asset_directory
    read -p "   Asset folders [true]: " asset_folders
    read -p "   Show missing assets [true]: " show_missing_assets
    read -p "   Download URL assets [false]: " download_url_assets
    read -p "   Show missing season assets [false]: " show_missing_season_assets
    read -p "   Show missing episode assets [false]: " show_missing_episode_assets
    
    echo ""
    echo "5. Scheduling and Operations"
    read -p "   Operations only [false]: " operations_only
    read -p "   Collections only [false]: " collections_only
    read -p "   Run order (collections/operations) [collections]: " run_order
    read -p "   Ignore schedules [false]: " ignore_schedules
    read -p "   Ignore ghost [false]: " ignore_ghost
    
    echo ""
    echo "6. Logging and Cache"
    read -p "   Cache [true]: " cache_enabled
    read -p "   Cache expiry (days) [60]: " cache_expiry
    read -p "   Log requests [false]: " log_requests
    read -p "   Run start/end [true]: " run_start_end
    read -p "   Show unconfigured [true]: " show_unconfigured
    read -p "   Show filtered [false]: " show_filtered
    read -p "   Show unmanaged [true]: " show_unmanaged
    read -p "   Show missing [true]: " show_missing
    
    # Create Kometa configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.yml" << EOF
# Kometa Advanced Configuration
# Generated by Surge Advanced Config Manager

libraries:
  Movies:
    collection_files:
      - pmm: basic
      - pmm: imdb
      - pmm: studio
      - pmm: genre
      - pmm: actor
      - pmm: director
      - pmm: writer
      - pmm: decade
      - pmm: year
    operations:
      delete_collections_with_less: ${collection_minimum:-2}
      delete_unmanaged_collections: ${delete_below_minimum:-false}
      mass_genre_update: tmdb
      mass_content_rating_update: omdb
      mass_audience_rating_update: mdb_tomatoes
      mass_critic_rating_update: mdb_tomatoes
      mass_user_rating_update: imdb
      mass_episode_critic_rating_update: imdb
      mass_episode_audience_rating_update: tmdb
      mass_poster_update: tmdb
      mass_background_update: tmdb

  TV Shows:
    collection_files:
      - pmm: basic
      - pmm: imdb
      - pmm: network
      - pmm: studio
      - pmm: genre
    operations:
      delete_collections_with_less: ${collection_minimum:-2}
      delete_unmanaged_collections: ${delete_below_minimum:-false}
      mass_genre_update: tmdb
      mass_content_rating_update: omdb
      mass_audience_rating_update: mdb_tomatoes
      mass_critic_rating_update: mdb_tomatoes
      mass_user_rating_update: imdb
      mass_episode_critic_rating_update: imdb
      mass_episode_audience_rating_update: tmdb
      mass_poster_update: tmdb
      mass_background_update: tmdb

settings:
  cache: ${cache_enabled:-true}
  cache_expiry: ${cache_expiry:-60}
  asset_directory: ${asset_directory:-/config/assets}
  asset_folders: ${asset_folders:-true}
  show_unmanaged: ${show_unmanaged:-true}
  show_unconfigured: ${show_unconfigured:-true}
  show_filtered: ${show_filtered:-false}
  show_options: false
  show_missing: ${show_missing:-true}
  show_missing_assets: ${show_missing_assets:-true}
  show_missing_season_assets: ${show_missing_season_assets:-false}
  show_missing_episode_assets: ${show_missing_episode_assets:-false}
  download_url_assets: ${download_url_assets:-false}
  create_asset_folders: ${asset_folders:-true}
  prioritize_assets: true
  dimensional_asset_rename: false
  delete_below_minimum: ${delete_below_minimum:-false}
  delete_not_scheduled: false
  run_again_delay: 2
  missing_only_released: ${missing_only_released:-false}
  only_filter_missing: ${only_filter_missing:-false}
  show_missing_season_assets: ${show_missing_season_assets:-false}
  show_missing_episode_assets: ${show_missing_episode_assets:-false}
  tvdb_language: en
  ignore_ids:
  ignore_imdb_ids:
  item_refresh_delay: 0
  playlist_sync_to_user: all
  verify_ssl: true
  check_nightly: false

plex:
  url: ${plex_url:-http://plex:32400}
  token: ${plex_token}
  timeout: ${plex_timeout:-60}
  clean_bundles: ${clean_bundles:-false}
  empty_trash: ${empty_trash:-false}
  optimize: false

tmdb:
  apikey: ${tmdb_key}
  language: ${tmdb_language:-en}
  cache_expiry: ${tmdb_cache_expiry:-60}

schedule:
  daily: 
    delete_collections: false
    missing_only_released: false

run_order:
  - ${run_order:-collections}
  - operations

operations_only: ${operations_only:-false}
collections_only: ${collections_only:-false}
run_start: ${run_start_end:-true}
run_end: ${run_start_end:-true}
ignore_schedules: ${ignore_schedules:-false}
ignore_ghost: ${ignore_ghost:-false}
log_requests: ${log_requests:-false}
EOF

    print_success "Kometa advanced configuration saved to $config_dir/config.yml"
    print_info "Restart Kometa to apply changes: docker-compose restart kometa"
}

configure_posterizarr_advanced() {
    print_header "Posterizarr Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/posterizarr"
    
    print_info "Configuring advanced Posterizarr settings..."
    
    echo "1. Media Server Configuration"
    read -p "   Media server type (plex/jellyfin/emby) [plex]: " media_server
    read -p "   Media server URL [http://plex:32400]: " server_url
    read -p "   Media server token/API key: " server_token
    read -p "   Library sections to process (comma-separated): " library_sections
    
    echo ""
    echo "2. Poster Generation Settings"
    read -p "   Enable poster overlays [true]: " enable_overlays
    read -p "   Default poster source (tmdb/tvdb/fanart) [tmdb]: " poster_source
    read -p "   Poster quality (low/medium/high) [high]: " poster_quality
    read -p "   Poster format (jpg/png) [jpg]: " poster_format
    read -p "   Custom overlay path (optional): " custom_overlay_path
    
    echo ""
    echo "3. Text Overlays"
    read -p "   Enable text overlays [true]: " text_overlays
    read -p "   Text font [Arial]: " text_font
    read -p "   Text size [72]: " text_size
    read -p "   Text color [white]: " text_color
    read -p "   Text position (top/bottom/center) [bottom]: " text_position
    read -p "   Add IMDb rating [true]: " add_imdb_rating
    read -p "   Add genre tags [false]: " add_genre_tags
    
    echo ""
    echo "4. Processing Options"
    read -p "   Backup original posters [true]: " backup_originals
    read -p "   Process movies [true]: " process_movies
    read -p "   Process TV shows [true]: " process_tv
    read -p "   Process collections [false]: " process_collections
    read -p "   Skip already processed [true]: " skip_processed
    
    echo ""
    echo "5. Image Sources and APIs"
    read -p "   TMDb API Key: " tmdb_key
    read -p "   TVDb API Key (optional): " tvdb_key
    read -p "   Fanart API Key (optional): " fanart_key
    read -p "   Prefer local assets [false]: " prefer_local
    read -p "   Download missing assets [true]: " download_missing
    
    echo ""
    echo "6. Scheduling and Performance"
    read -p "   Process interval (hours) [24]: " process_interval
    read -p "   Max concurrent processes [2]: " max_concurrent
    read -p "   Image download timeout (seconds) [30]: " download_timeout
    read -p "   Enable dry run mode [false]: " dry_run
    
    echo ""
    echo "7. Logging and Notifications"
    read -p "   Log level (DEBUG/INFO/WARNING/ERROR) [INFO]: " log_level
    read -p "   Enable progress logging [true]: " progress_logging
    read -p "   Log file rotation [true]: " log_rotation
    read -p "   Enable Discord notifications [false]: " discord_enabled
    if [[ "${discord_enabled:-false}" == "true" ]]; then
        read -p "   Discord webhook URL: " discord_webhook
    fi
    
    # Create Posterizarr configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.yml" << EOF
# Posterizarr Advanced Configuration
# Generated by Surge Advanced Config Manager

media_server:
  type: "${media_server:-plex}"
  url: "${server_url:-http://plex:32400}"
  token: "${server_token}"
  library_sections: [$(echo "${library_sections}" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')] 

poster_settings:
  enable_overlays: ${enable_overlays:-true}
  source: "${poster_source:-tmdb}"
  quality: "${poster_quality:-high}"
  format: "${poster_format:-jpg}"
  custom_overlay_path: "${custom_overlay_path}"

text_overlays:
  enabled: ${text_overlays:-true}
  font: "${text_font:-Arial}"
  size: ${text_size:-72}
  color: "${text_color:-white}"
  position: "${text_position:-bottom}"
  include_imdb_rating: ${add_imdb_rating:-true}
  include_genre_tags: ${add_genre_tags:-false}

processing:
  backup_originals: ${backup_originals:-true}
  process_movies: ${process_movies:-true}
  process_tv_shows: ${process_tv:-true}
  process_collections: ${process_collections:-false}
  skip_already_processed: ${skip_processed:-true}

api_keys:
  tmdb: "${tmdb_key}"
  tvdb: "${tvdb_key}"
  fanart: "${fanart_key}"

asset_settings:
  prefer_local_assets: ${prefer_local:-false}
  download_missing_assets: ${download_missing:-true}
  assets_path: "/assets"
  backup_path: "/assets/backups"

scheduling:
  interval_hours: ${process_interval:-24}
  max_concurrent_processes: ${max_concurrent:-2}
  download_timeout_seconds: ${download_timeout:-30}
  dry_run_mode: ${dry_run:-false}

logging:
  level: "${log_level:-INFO}"
  enable_progress_logging: ${progress_logging:-true}
  log_file_rotation: ${log_rotation:-true}
  log_file_max_size_mb: 10
  log_file_backup_count: 5

notifications:
  discord:
    enabled: ${discord_enabled:-false}$([ "${discord_enabled:-false}" = "true" ] && echo "
    webhook_url: \"${discord_webhook}\"" || echo "")

# Overlay Templates
overlay_templates:
  imdb_rating:
    enabled: ${add_imdb_rating:-true}
    position: "bottom_right"
    style: "modern"
    
  genre_tags:
    enabled: ${add_genre_tags:-false}
    position: "top_left"
    max_tags: 3
    
  quality_badge:
    enabled: false
    position: "top_right"
    
paths:
  assets: "/assets"
  logs: "/logs"
  temp: "/tmp/posterizarr"
EOF

    print_success "Posterizarr advanced configuration saved to $config_dir/config.yml"
    print_info "Restart Posterizarr to apply changes: docker-compose restart posterizarr"
}

configure_scanly_advanced() {
    print_warning "Scanly advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_cinesync_advanced() {
    print_header "CineSync Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/cinesync"
    local env_file="$config_dir/.env"
    
    print_info "Configuring advanced CineSync settings..."
    
    echo "1. Source and Destination Configuration"
    read -p "   Source directory [${STORAGE_PATH}/downloads/Zurg/__all__]: " source_dir
    read -p "   Destination directory [${STORAGE_PATH}/media]: " dest_dir
    read -p "   Use source structure [false]: " use_source_structure
    
    echo ""
    echo "2. Media Organization"
    read -p "   Enable CineSync layout [true]: " layout_enabled
    read -p "   Enable anime separation [true]: " anime_separation
    read -p "   Enable 4K separation [false]: " separation_4k
    read -p "   Enable kids separation [false]: " kids_separation
    
    echo ""
    echo "3. Custom Folder Names"
    read -p "   Custom TV show folder name [TV Series]: " tv_folder
    read -p "   Custom 4K TV folder name [4K Series]: " tv_4k_folder
    read -p "   Custom anime TV folder name [Anime Series]: " anime_tv_folder
    read -p "   Custom movie folder name [Movies]: " movie_folder
    read -p "   Custom 4K movie folder name [4K Movies]: " movie_4k_folder
    read -p "   Custom anime movie folder name [Anime Movies]: " anime_movie_folder
    read -p "   Custom kids movie folder name [Kids Movies]: " kids_movie_folder
    read -p "   Custom kids TV folder name [Kids Series]: " kids_tv_folder
    
    echo ""
    echo "4. TMDb Configuration"
    read -p "   TMDb API Key: " tmdb_key
    read -p "   Language [English]: " language
    read -p "   Enable anime scanning [false]: " anime_scan
    read -p "   Enable TMDB folder ID [false]: " tmdb_folder_id
    read -p "   Enable IMDB folder ID [false]: " imdb_folder_id
    read -p "   Enable TVDB folder ID [false]: " tvdb_folder_id
    
    echo ""
    echo "5. File Processing"
    read -p "   Enable renaming [false]: " rename_enabled
    read -p "   Enable MediaInfo parsing [false]: " mediainfo_parser
    read -p "   Rename tags (Resolution/Quality/Source) [Resolution]: " rename_tags
    read -p "   Skip extras folder [true]: " skip_extras
    read -p "   Junk file max size (MB) [5]: " junk_max_size
    read -p "   Allowed extensions [.mp4,.mkv,.srt,.avi,.mov,.divx,.strm]: " allowed_extensions
    
    echo ""
    echo "6. Performance Settings"
    read -p "   Max CPU cores [1]: " max_cores
    read -p "   Max processes [15]: " max_processes
    read -p "   Sleep time between scans (seconds) [60]: " sleep_time
    read -p "   Symlink cleanup interval (seconds) [600]: " cleanup_interval
    
    echo ""
    echo "7. Plex Integration"
    read -p "   Enable Plex updates [false]: " plex_enabled
    if [[ "${plex_enabled:-false}" == "true" ]]; then
        read -p "   Plex URL [http://localhost:32400]: " plex_url
        read -p "   Plex Token: " plex_token
    fi
    
    echo ""
    echo "8. Server Configuration"
    read -p "   CineSync IP [0.0.0.0]: " cinesync_ip
    read -p "   API Port [8082]: " api_port
    read -p "   UI Port [5173]: " ui_port
    read -p "   Enable authentication [true]: " auth_enabled
    read -p "   Username [admin]: " username
    read -s -p "   Password [admin]: " password
    echo ""
    
    # Create CineSync environment configuration
    mkdir -p "$config_dir"
    
    cat > "$env_file" << EOF
# CineSync Advanced Configuration
# Generated by Surge Advanced Config Manager

# Directory Paths
SOURCE_DIR=${source_dir:-${STORAGE_PATH}/downloads/Zurg/__all__}
DESTINATION_DIR=${dest_dir:-${STORAGE_PATH}/media}
USE_SOURCE_STRUCTURE=${use_source_structure:-false}

# Media Organization Configuration  
CINESYNC_LAYOUT=${layout_enabled:-true}
ANIME_SEPARATION=${anime_separation:-true}
4K_SEPARATION=${separation_4k:-false}
KIDS_SEPARATION=${kids_separation:-false}

# Custom folder paths
CUSTOM_SHOW_FOLDER=${tv_folder:-TV Series}
CUSTOM_4KSHOW_FOLDER=${tv_4k_folder:-4K Series}
CUSTOM_ANIME_SHOW_FOLDER=${anime_tv_folder:-Anime Series}
CUSTOM_MOVIE_FOLDER=${movie_folder:-Movies}
CUSTOM_4KMOVIE_FOLDER=${movie_4k_folder:-4K Movies}
CUSTOM_ANIME_MOVIE_FOLDER=${anime_movie_folder:-Anime Movies}
CUSTOM_KIDS_MOVIE_FOLDER=${kids_movie_folder:-Kids Movies}
CUSTOM_KIDS_SHOW_FOLDER=${kids_tv_folder:-Kids Series}

# Resolution-Based Organization
SHOW_RESOLUTION_STRUCTURE=false
MOVIE_RESOLUTION_STRUCTURE=false

# Logging Configuration
LOG_LEVEL=INFO

# TMDb/IMDB Configuration
TMDB_API_KEY=${tmdb_key}
LANGUAGE=${language:-English}
ANIME_SCAN=${anime_scan:-false}
TMDB_FOLDER_ID=${tmdb_folder_id:-false}
IMDB_FOLDER_ID=${imdb_folder_id:-false}
TVDB_FOLDER_ID=${tvdb_folder_id:-false}
RENAME_ENABLED=${rename_enabled:-false}
MEDIAINFO_PARSER=${mediainfo_parser:-false}
RENAME_TAGS=${rename_tags:-Resolution}

# Movie Collection Settings
MOVIE_COLLECTION_ENABLED=false

# System Configuration
RELATIVE_SYMLINK=false
MAX_CORES=${max_cores:-1}
MAX_PROCESSES=${max_processes:-15}

# File Handling Configuration
SKIP_EXTRAS_FOLDER=${skip_extras:-true}
JUNK_MAX_SIZE_MB=${junk_max_size:-5}
ALLOWED_EXTENSIONS=${allowed_extensions:-.mp4,.mkv,.srt,.avi,.mov,.divx,.strm}
SKIP_ADULT_PATTERNS=true

# Real-Time Monitoring Configuration
SLEEP_TIME=${sleep_time:-60}
SYMLINK_CLEANUP_INTERVAL=${cleanup_interval:-600}

# Plex Integration Configuration  
ENABLE_PLEX_UPDATE=${plex_enabled:-false}
PLEX_URL=${plex_url:-http://localhost:32400}
PLEX_TOKEN=${plex_token}

# CineSync Server Configuration
CINESYNC_IP=${cinesync_ip:-0.0.0.0}
CINESYNC_API_PORT=${api_port:-8082}
CINESYNC_UI_PORT=${ui_port:-5173}
CINESYNC_AUTH_ENABLED=${auth_enabled:-true}
CINESYNC_USERNAME=${username:-admin}
CINESYNC_PASSWORD=${password:-admin}

# MediaHub Service Configuration
MEDIAHUB_AUTO_START=true
RTM_AUTO_START=false
FILE_OPERATIONS_AUTO_MODE=true

# Database Configuration
DB_THROTTLE_RATE=100
DB_MAX_RETRIES=10
DB_RETRY_DELAY=1.0
DB_BATCH_SIZE=1000
DB_MAX_WORKERS=20
EOF

    print_success "CineSync advanced configuration saved to $env_file"
    print_info "Restart CineSync to apply changes: docker-compose restart cinesync"
}

configure_imagemaid_advanced() {
    print_warning "ImageMaid advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_gaps_advanced() {
    print_header "GAPS Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/gaps"
    
    print_info "Configuring advanced GAPS settings..."
    
    echo "1. Plex Server Configuration"
    read -p "   Plex server URL [http://plex:32400]: " plex_url
    read -p "   Plex token: " plex_token
    read -p "   Plex machine identifier (optional): " plex_machine_id
    
    echo ""
    echo "2. Library Selection"
    read -p "   Movie library name [Movies]: " movie_library
    read -p "   Enable multiple library support [false]: " multi_library
    if [[ "${multi_library:-false}" == "true" ]]; then
        read -p "   Additional library names (comma-separated): " additional_libs
    fi
    
    echo ""
    echo "3. Collection Analysis"
    read -p "   Minimum collection size [5]: " min_collection_size
    read -p "   Check popular collections [true]: " check_popular
    read -p "   Check new releases [true]: " check_new_releases
    read -p "   Check award winners [true]: " check_awards
    read -p "   Check franchises [true]: " check_franchises
    
    echo ""
    echo "4. TMDb Integration"
    read -p "   TMDb API Key: " tmdb_key
    read -p "   TMDb language [en]: " tmdb_language
    read -p "   Include adult content [false]: " include_adult
    read -p "   Minimum vote average [6.0]: " min_vote_average
    read -p "   Minimum vote count [100]: " min_vote_count
    
    echo ""
    echo "5. Radarr Integration"
    read -p "   Enable Radarr integration [true]: " radarr_enabled
    if [[ "${radarr_enabled:-true}" == "true" ]]; then
        read -p "   Radarr URL [http://radarr:7878]: " radarr_url
        read -p "   Radarr API Key: " radarr_api_key
        read -p "   Quality profile ID [1]: " quality_profile
        read -p "   Root folder path [/movies]: " root_folder
        read -p "   Auto-add to Radarr [false]: " auto_add
    fi
    
    echo ""
    echo "6. Notification Settings"
    read -p "   Enable email notifications [false]: " email_enabled
    if [[ "${email_enabled:-false}" == "true" ]]; then
        read -p "   SMTP server: " smtp_server
        read -p "   SMTP port [587]: " smtp_port
        read -p "   SMTP username: " smtp_username
        read -s -p "   SMTP password: " smtp_password
        echo ""
        read -p "   From email: " from_email
        read -p "   To email: " to_email
    fi
    
    echo ""
    echo "7. Scheduling and Performance"
    read -p "   Scan frequency (hours) [24]: " scan_frequency
    read -p "   Max concurrent API requests [5]: " max_requests
    read -p "   Request delay (ms) [1000]: " request_delay
    read -p "   Enable caching [true]: " enable_caching
    read -p "   Cache duration (hours) [24]: " cache_duration
    
    # Create GAPS configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/application.yml" << EOF
# GAPS Advanced Configuration
# Generated by Surge Advanced Config Manager

server:
  port: 8484
  address: 0.0.0.0
  ssl:
    enabled: false
    
plex:
  server:
    address: "${plex_url:-http://plex:32400}"
    token: "${plex_token}"
    machineIdentifier: "${plex_machine_id}"
  libraries:
    - name: "${movie_library:-Movies}"
      type: "movie"
      enabled: true
$([ "${multi_library:-false}" = "true" ] && [ -n "${additional_libs}" ] && echo "${additional_libs}" | tr ',' '\n' | sed 's/^[ ]*/    - name: "/' | sed 's/$/"\n      type: "movie"\n      enabled: true/')

collections:
  minimumSize: ${min_collection_size:-5}
  checkPopular: ${check_popular:-true}
  checkNewReleases: ${check_new_releases:-true}
  checkAwardWinners: ${check_awards:-true}
  checkFranchises: ${check_franchises:-true}

tmdb:
  apiKey: "${tmdb_key}"
  language: "${tmdb_language:-en}"
  includeAdult: ${include_adult:-false}
  filters:
    minimumVoteAverage: ${min_vote_average:-6.0}
    minimumVoteCount: ${min_vote_count:-100}

radarr:
  enabled: ${radarr_enabled:-true}
  url: "${radarr_url:-http://radarr:7878}"
  apiKey: "${radarr_api_key}"
  qualityProfileId: ${quality_profile:-1}
  rootFolderPath: "${root_folder:-/movies}"
  autoAdd: ${auto_add:-false}
  searchForMovie: true
  monitoredState: true

notifications:
  email:
    enabled: ${email_enabled:-false}$([ "${email_enabled:-false}" = "true" ] && cat << EOF2

    smtp:
      server: "${smtp_server}"
      port: ${smtp_port:-587}
      username: "${smtp_username}"
      password: "${smtp_password}"
      ssl: true
    from: "${from_email}"
    to: "${to_email}"
EOF2
)

scheduling:
  scanFrequencyHours: ${scan_frequency:-24}
  
performance:
  maxConcurrentRequests: ${max_requests:-5}
  requestDelayMs: ${request_delay:-1000}
  caching:
    enabled: ${enable_caching:-true}
    durationHours: ${cache_duration:-24}

logging:
  level: INFO
  file: /usr/data/logs/gaps.log
  
database:
  location: /usr/data/gaps.db
  backupEnabled: true
  backupFrequencyDays: 7
EOF

    print_success "GAPS advanced configuration saved to $config_dir/application.yml"
    print_info "Restart GAPS to apply changes: docker-compose restart gaps"
}

configure_cli_debrid_advanced() {
    print_header "CLI-Debrid Advanced Configuration"
    
    local config_dir="${STORAGE_PATH:-/opt/surge}/config/cli_debrid"
    
    print_info "Configuring advanced CLI-Debrid settings..."
    
    echo "1. Debrid Service Configuration"
    read -p "   Real-Debrid API Key: " rd_api_key
    read -p "   AllDebrid API Key (optional): " ad_api_key  
    read -p "   Premiumize API Key (optional): " pm_api_key
    read -p "   Default debrid service (realdebrid/alldebrid/premiumize) [realdebrid]: " default_service
    
    echo ""
    echo "2. Download Management"
    read -p "   Downloads directory [/downloads]: " downloads_dir
    read -p "   Max concurrent downloads [5]: " max_concurrent
    read -p "   Check interval (seconds) [30]: " check_interval
    read -p "   Retry failed downloads [true]: " retry_failed
    read -p "   Max retry attempts [3]: " max_retries
    
    echo ""
    echo "3. Quality and Filtering"
    read -p "   Preferred video quality [1080p]: " preferred_quality
    read -p "   Fallback quality [720p]: " fallback_quality
    read -p "   Minimum file size (MB) [100]: " min_file_size
    read -p "   Maximum file size (GB) [50]: " max_file_size
    read -p "   Preferred codecs (h264,h265,x264,x265) [h264,h265]: " preferred_codecs
    
    echo ""
    echo "4. Content Organization"
    read -p "   Auto-organize downloads [true]: " auto_organize
    read -p "   Movies subfolder [movies]: " movies_subfolder
    read -p "   TV shows subfolder [tv]: " tv_subfolder
    read -p "   Create year folders for movies [true]: " year_folders
    read -p "   Create season folders for TV [true]: " season_folders
    
    echo ""
    echo "5. Web Interface Settings"
    read -p "   Web interface port [5000]: " web_port
    read -p "   Enable authentication [true]: " enable_auth
    if [[ "${enable_auth:-true}" == "true" ]]; then
        read -p "   Username [admin]: " web_username
        read -s -p "   Password: " web_password
        echo ""
    fi
    
    echo ""
    echo "6. Automation Features"
    read -p "   Auto-delete completed downloads [false]: " auto_delete
    read -p "   Monitor downloads folder [true]: " monitor_folder
    read -p "   Enable real-time processing [true]: " realtime_processing
    read -p "   Cleanup incomplete files [true]: " cleanup_incomplete
    
    echo ""
    echo "7. Logging and Notifications"
    read -p "   Log level (DEBUG/INFO/WARNING/ERROR) [INFO]: " log_level
    read -p "   Enable file logging [true]: " file_logging
    read -p "   Log retention days [30]: " log_retention
    read -p "   Enable Discord notifications [false]: " discord_enabled
    if [[ "${discord_enabled:-false}" == "true" ]]; then
        read -p "   Discord webhook URL: " discord_webhook
    fi
    
    # Create CLI-Debrid configuration
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.yml" << EOF
# CLI-Debrid Advanced Configuration
# Generated by Surge Advanced Config Manager

debrid_services:
  real_debrid:
    api_key: "${rd_api_key}"
    enabled: true
    priority: 1
    
  all_debrid:
    api_key: "${ad_api_key}"
    enabled: $([ -n "${ad_api_key}" ] && echo "true" || echo "false")
    priority: 2
    
  premiumize:
    api_key: "${pm_api_key}"
    enabled: $([ -n "${pm_api_key}" ] && echo "true" || echo "false")
    priority: 3

default_service: "${default_service:-realdebrid}"

downloads:
  directory: "${downloads_dir:-/downloads}"
  max_concurrent: ${max_concurrent:-5}
  check_interval: ${check_interval:-30}
  retry_failed: ${retry_failed:-true}
  max_retries: ${max_retries:-3}

quality:
  preferred_quality: "${preferred_quality:-1080p}"
  fallback_quality: "${fallback_quality:-720p}"
  min_file_size_mb: ${min_file_size:-100}
  max_file_size_gb: ${max_file_size:-50}
  preferred_codecs: [$(echo "${preferred_codecs:-h264,h265}" | sed 's/,/", "/g' | sed 's/^/"/' | sed 's/$/"/')] 

organization:
  auto_organize: ${auto_organize:-true}
  movies_subfolder: "${movies_subfolder:-movies}"
  tv_subfolder: "${tv_subfolder:-tv}"
  create_year_folders: ${year_folders:-true}
  create_season_folders: ${season_folders:-true}

web_interface:
  port: ${web_port:-5000}
  host: "0.0.0.0"
  authentication:
    enabled: ${enable_auth:-true}$([ "${enable_auth:-true}" = "true" ] && cat << EOF2

    username: "${web_username:-admin}"
    password: "${web_password}"
EOF2
)

automation:
  auto_delete_completed: ${auto_delete:-false}
  monitor_downloads_folder: ${monitor_folder:-true}
  realtime_processing: ${realtime_processing:-true}
  cleanup_incomplete: ${cleanup_incomplete:-true}

logging:
  level: "${log_level:-INFO}"
  file_logging: ${file_logging:-true}
  log_retention_days: ${log_retention:-30}
  
notifications:
  discord:
    enabled: ${discord_enabled:-false}$([ "${discord_enabled:-false}" = "true" ] && echo "
    webhook_url: \"${discord_webhook}\"" || echo "")

# Integration with other Surge services
integrations:
  radarr:
    enabled: true
    url: "http://radarr:7878"
    
  sonarr:
    enabled: true
    url: "http://sonarr:8989"
    
  prowlarr:
    enabled: true
    url: "http://prowlarr:9696"
EOF

    print_success "CLI-Debrid advanced configuration saved to $config_dir/config.yml"
    print_info "Restart CLI-Debrid to apply changes: docker-compose restart cli-debrid"
}

configure_homepage_advanced() {
    print_warning "Homepage advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

# Main command routing
main() {
    case "${1:-help}" in
        config)
            if [ -z "${2:-}" ]; then
                print_error "Service not specified"
                echo "Usage: ./surge advanced config <service>"
                echo "Run './surge advanced list' to see available services"
                exit 1
            fi
            configure_service "$2"
            ;;
        list)
            list_services
            ;;
        backup)
            backup_configs
            ;;
        validate)
            if [ -z "${2:-}" ]; then
                print_error "Service not specified"
                echo "Usage: ./surge advanced validate <service>"
                exit 1
            fi
            validate_config "$2"
            ;;
        reset)
            if [ -z "${2:-}" ]; then
                print_error "Service not specified"
                echo "Usage: ./surge advanced reset <service>"
                exit 1
            fi
            print_warning "Reset functionality not yet implemented"
            ;;
        export|import)
            print_warning "$1 functionality not yet implemented"
            ;;
        restore)
            print_warning "Restore functionality not yet implemented"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Run './surge advanced help' for usage information"
            exit 1
            ;;
    esac
}

# Check if running directly or being sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
