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
    print_warning "NZBGet advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_rdt_client_advanced() {
    print_warning "RDT-Client advanced configuration not yet implemented"
    print_info "This will be added in a future update"
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
    print_warning "Decypharr advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_kometa_advanced() {
    print_warning "Kometa advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_posterizarr_advanced() {
    print_warning "Posterizarr advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_scanly_advanced() {
    print_warning "Scanly advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_cinesync_advanced() {
    print_warning "CineSync advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_imagemaid_advanced() {
    print_warning "ImageMaid advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_gaps_advanced() {
    print_warning "GAPS advanced configuration not yet implemented"
    print_info "This will be added in a future update"
}

configure_cli_debrid_advanced() {
    print_warning "CLI-Debrid advanced configuration not yet implemented"
    print_info "This will be added in a future update"
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
