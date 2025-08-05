#!/bin/bash

# ===========================================
# SHARED CONFIGURATION MANAGEMENT
# ===========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Shared configuration variables that get propagated to all services
SHARED_VARS=(
    "DISCORD_WEBHOOK_URL"
    "TMDB_API_KEY"
    "TRAKT_CLIENT_ID"
    "TRAKT_CLIENT_SECRET"
    "NOTIFICATION_TITLE_PREFIX"
    "TIMEZONE"
    "PUID"
    "PGID"
)

# Service-specific config file mappings
declare -A SERVICE_CONFIGS=(
    ["kometa"]="config/kometa/config.yml"
    ["posterizarr"]="config/posterizarr/config.yml"
    ["radarr"]="config/radarr/config.xml"
    ["sonarr"]="config/sonarr/config.xml"
    ["prowlarr"]="config/prowlarr/config.xml"
    ["tautulli"]="config/tautulli/config.ini"
    ["imagemaid"]="config/imagemaid/config.yml"
    ["zurg"]="config/zurg/config.yml"
)

# Discord webhook notification function
send_discord_notification() {
    local title="$1"
    local description="$2"
    local notification_type="${3:-system}"  # updates, processing, errors, media, system
    local color="${4:-3447003}"  # Default blue
    local webhook_url="${5:-$DISCORD_WEBHOOK_URL}"
    
    if [ -z "$webhook_url" ]; then
        return 0  # Silently skip if no webhook configured
    fi
    
    # Check if this notification type is enabled
    case "$notification_type" in
        "updates")
            if [ "${DISCORD_NOTIFY_UPDATES:-false}" != "true" ]; then
                return 0
            fi
            ;;
        "processing")
            if [ "${DISCORD_NOTIFY_PROCESSING:-false}" != "true" ]; then
                return 0
            fi
            ;;
        "errors")
            if [ "${DISCORD_NOTIFY_ERRORS:-false}" != "true" ]; then
                return 0
            fi
            ;;
        "media")
            if [ "${DISCORD_NOTIFY_MEDIA:-false}" != "true" ]; then
                return 0
            fi
            ;;
        "system")
            if [ "${DISCORD_NOTIFY_SYSTEM:-false}" != "true" ]; then
                return 0
            fi
            ;;
    esac
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    local hostname=$(hostname)
    
    local payload=$(cat << EOF
{
  "embeds": [
    {
      "title": "${NOTIFICATION_TITLE_PREFIX:-Surge} - $title",
      "description": "$description",
      "color": $color,
      "timestamp": "$timestamp",
      "footer": {
        "text": "Surge on $hostname"
      },
      "fields": [
        {
          "name": "Host",
          "value": "$hostname",
          "inline": true
        },
        {
          "name": "Time",
          "value": "$(date)",
          "inline": true
        }
      ]
    }
  ]
}
EOF
    )
    
    curl -s -H "Content-Type: application/json" \
         -d "$payload" \
         "$webhook_url" > /dev/null 2>&1
}

# Update all service configurations with shared variables
propagate_shared_config() {
    print_info "Propagating shared configuration to all services..."
    
    # Load current .env file
    if [ -f "$PROJECT_DIR/.env" ]; then
        source "$PROJECT_DIR/.env"
    else
        print_error "No .env file found"
        return 1
    fi
    
    # Update Kometa config
    update_kometa_config
    # Update Posterizarr config
    update_posterizarr_config
    # Update Zurg config
    update_zurg_config
    
    # Update Tautulli config for Discord notifications
    update_tautulli_config
    
    # Update notification configs for Radarr/Sonarr/Prowlarr
    update_arr_configs
    
    print_success "Shared configuration propagated to all services"
    
    # Send notification about config update
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        send_discord_notification \
            "Configuration Updated" \
            "Shared configuration has been propagated to all services" \
            "system" \
            "3066993"  # Green color
    fi
}

    


    # Add webhook configuration if available and enabled
    if [ -n "$DISCORD_WEBHOOK_URL" ] && [ "${DISCORD_NOTIFY_PROCESSING:-false}" = "true" ]; then
        cat >> "$config_file" << EOF

webhooks:
  error: $DISCORD_WEBHOOK_URL
  version: $DISCORD_WEBHOOK_URL
  run_start: $DISCORD_WEBHOOK_URL
  run_end: $DISCORD_WEBHOOK_URL
  changes:
    - $DISCORD_WEBHOOK_URL

EOF
    fi

    # Add TMDB configuration if available
    if [ -n "$TMDB_API_KEY" ]; then
        cat >> "$config_file" << EOF

tmdb:
  apikey: $TMDB_API_KEY
  language: en
  cache_expiration: 60

EOF
    fi

    # Add Trakt configuration if available
    if [ -n "$TRAKT_CLIENT_ID" ]; then
        cat >> "$config_file" << EOF

trakt:
  client_id: $TRAKT_CLIENT_ID
  client_secret: $TRAKT_CLIENT_SECRET
  authorization:
    access_token:
    token_type:
    expires_in:
    refresh_token:
    scope: public
    created_at:

EOF
    fi
general:
database:

# Update Posterizarr configuration
update_posterizarr_config() {
    local config_file="$PROJECT_DIR/config/posterizarr/config.yml"
    local config_dir="$(dirname "$config_file")"
    
    mkdir -p "$config_dir"
    
    cat > "$config_file" << EOF
# Posterizarr Configuration - Auto-generated by Surge
# Last updated: $(date)

general:
  assets_path: /shared-assets
  media_paths:
    movies: /media/movies
    tv: /media/tv
  poster_formats: 
    - jpg
    - png
  quality: high
  
processing:
  resize_posters: true
  max_width: 2000
  max_height: 3000
  optimize_images: true
  backup_originals: true

sources:
  tmdb:
    enabled: ${TMDB_API_KEY:+true}
    api_key: ${TMDB_API_KEY:-}
    preferred_language: en
  
  fanart:
    enabled: true
    api_key: ${FANART_API_KEY:-}

EOF

    # Add Discord notifications if available and processing notifications enabled
    if [ -n "$DISCORD_WEBHOOK_URL" ] && [ "${DISCORD_NOTIFY_PROCESSING:-false}" = "true" ]; then
        cat >> "$config_file" << EOF

notifications:
  discord:
    enabled: true
    webhook_url: $DISCORD_WEBHOOK_URL
    notify_on:
      - poster_updated
      - errors
      - batch_complete
    title_prefix: "${NOTIFICATION_TITLE_PREFIX:-Surge} - Posterizarr"

EOF
    fi
}

# Update Zurg configuration
update_zurg_config() {
    local config_file="$PROJECT_DIR/config/zurg/config.yml"
    local config_dir="$(dirname "$config_file")"
    
    mkdir -p "$config_dir"
    
    # Use template if config doesn't exist or if force update is requested
    if [ ! -f "$config_file" ] || [ "${FORCE_CONFIG_UPDATE:-false}" = "true" ]; then
        print_info "Creating Zurg configuration from template..."
        
        # Copy template and replace placeholders
        if [ -f "$PROJECT_DIR/configs/zurg-config.yml.template" ]; then
            cp "$PROJECT_DIR/configs/zurg-config.yml.template" "$config_file"
            
            # Replace placeholders with actual values
            if [ -n "$RD_API_TOKEN" ]; then
                sed -i "s/RD_API_TOKEN_HERE/$RD_API_TOKEN/g" "$config_file"
            else
                print_warning "RD_API_TOKEN not set. Zurg will need manual configuration."
            fi
            
            # Adjust for media server type
            case "${MEDIA_SERVER:-plex}" in
                plex|Plex)
                    # Keep default Plex configuration
                    ;;
                jellyfin|Jellyfin)
                    sed -i 's/plex_update\.sh/jellyfin_update.sh/g' "$config_file"
                    ;;
                emby|Emby)
                    sed -i 's/plex_update\.sh/emby_update.sh/g' "$config_file"
                    ;;
            esac
            
            print_success "Zurg configuration created successfully"
            
            # Copy Plex update script if template exists
            if [ -f "$PROJECT_DIR/configs/plex_update.sh.template" ]; then
                cp "$PROJECT_DIR/configs/plex_update.sh.template" "$config_dir/plex_update.sh"
                chmod +x "$config_dir/plex_update.sh"
                print_info "Plex update script copied to Zurg config directory"
            fi
        else
            print_warning "Zurg template not found at $PROJECT_DIR/configs/zurg-config.yml.template"
            print_info "Creating minimal Zurg configuration..."
            
            cat > "$config_file" << EOF
# Zurg Configuration - Auto-generated by Surge
# Last updated: $(date)
zurg: v1
token: ${RD_API_TOKEN:-REPLACE_WITH_YOUR_RD_TOKEN}
check_for_changes_every_secs: 10
enable_repair: true
auto_delete_rar_torrents: true

directories:
  anime:
    group_order: 10
    group: media
    filters:
      - regex: /\\b[a-fA-F0-9]{8}\\b/
      - any_file_inside_regex: /\\b[a-fA-F0-9]{8}\\b/
  shows:
    group_order: 20
    group: media
    filters:
      - has_episodes: true
  movies:
    group_order: 30
    group: media
    only_show_the_biggest_file: true
    filters:
      - regex: /.*/
EOF
        fi
    else
        print_info "Zurg configuration already exists at $config_file"
    fi
}

# Update Tautulli configuration
update_tautulli_config() {
    local config_file="$PROJECT_DIR/config/tautulli/config.ini"
    local config_dir="$(dirname "$config_file")"
    
    mkdir -p "$config_dir"
    
    # Only create if doesn't exist (Tautulli manages its own config)
    if [ ! -f "$config_file" ]; then
        cat > "$config_file" << EOF
# Tautulli Configuration - Auto-generated by Surge
# Last updated: $(date)

[General]
check_github = 1
check_github_on_startup = 1
update_db_on_startup = 0
backup_dir = /config/backups
cache_dir = /config/cache
log_dir = /config/logs

[PlexMediaServer]
plex_name = Plex
plex_ip = plex
plex_port = 32400
plex_ssl = 0
plex_token = ${PLEX_TOKEN:-}

EOF
    fi
    
    # Add Discord webhook configuration if available and media notifications enabled
    if [ -n "$DISCORD_WEBHOOK_URL" ] && [ "${DISCORD_NOTIFY_MEDIA:-false}" = "true" ] && [ -f "$config_file" ]; then
        # Check if Discord webhook already configured
        if ! grep -q "discord_webhook_url" "$config_file"; then
            cat >> "$config_file" << EOF

[Webhooks]
discord_webhook_url = $DISCORD_WEBHOOK_URL
discord_enabled = 1
discord_events = play,stop,error

EOF
        fi
    fi
}

# Update Radarr/Sonarr/Prowlarr configurations
update_arr_configs() {
    local services=("radarr" "sonarr" "prowlarr")
    
    for service in "${services[@]}"; do
        local config_file="$PROJECT_DIR/config/$service/config.xml"
        local config_dir="$(dirname "$config_file")"
        
        mkdir -p "$config_dir"
        
        # Create basic config if it doesn't exist
        if [ ! -f "$config_file" ]; then
            cat > "$config_file" << EOF
<Config>
  <Port>$([ "$service" = "radarr" ] && echo "7878" || echo "8989")</Port>
  <SslPort>9898</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <ApiKey></ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <Branch>master</Branch>
  <LogLevel>info</LogLevel>
  <SslCertPath></SslCertPath>
  <SslCertPassword></SslCertPassword>
  <UrlBase></UrlBase>
  <InstanceName>$service</InstanceName>
  <UpdateMechanism>Docker</UpdateMechanism>
  <Theme>auto</Theme>
</Config>
EOF
        fi
    done
}

# Check for container updates and send notifications
check_and_notify_updates() {
    print_info "Checking for container updates..."
    
    # Use the new comprehensive update monitor if available
    local update_monitor="$PROJECT_DIR/scripts/update-monitor.py"
    if [ -f "$update_monitor" ] && command -v python3 &> /dev/null; then
        print_info "Using enhanced update monitoring system..."
        
        # Run update check
        if python3 "$update_monitor" --check-once; then
            print_success "All containers are up to date"
            return 0
        else
            print_warning "Container updates are available"
            send_discord_notification \
                "Container Updates Available" \
                "Updates have been detected for your Surge media stack.\n\nRun \`./surge --update\` to apply updates safely." \
                "updates" \
                "16776960"  # Orange color
            return 1
        fi
    fi
    
    # Fallback to legacy update checking if new system unavailable
    print_warning "Using legacy update checking (install python3 for enhanced monitoring)"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found"
        return 1
    fi
    
    # Get list of running Surge containers
    local containers=$(docker ps --filter "label=surge" --format "{{.Names}}" 2>/dev/null)
    
    if [ -z "$containers" ]; then
        print_warning "No Surge containers found"
        return 0
    fi
    
    local updates_available=()
    local total_containers=0
    
    # Check each container for updates
    while IFS= read -r container; do
        if [ -n "$container" ]; then
            total_containers=$((total_containers + 1))
            local image=$(docker inspect "$container" --format='{{.Config.Image}}' 2>/dev/null)
            
            if [ -n "$image" ]; then
                # Pull latest image
                print_info "Checking updates for $container ($image)..."
                local pull_output=$(docker pull "$image" 2>&1)
                
                # Check if image was updated
                if echo "$pull_output" | grep -q "Downloaded newer image\|Pull complete"; then
                    updates_available+=("$container")
                    print_warning "Update available for $container"
                fi
            fi
        fi
    done <<< "$containers"
    
    # Send notification if updates are available
    if [ ${#updates_available[@]} -gt 0 ]; then
        local update_list=$(printf "%s\n" "${updates_available[@]}" | sed 's/^/• /')
        
        send_discord_notification \
            "Container Updates Available" \
            "Updates are available for the following services:\n\n$update_list\n\nUse \`./surge --update\` to apply updates." \
            "updates" \
            "16776960"  # Orange color
            
        print_warning "${#updates_available[@]} container(s) have updates available"
        echo "Updated containers:"
        printf "%s\n" "${updates_available[@]}" | sed 's/^/  - /'
    else
        print_success "All containers are up to date"
        
        # Send success notification (optional, only if explicitly requested)
        if [ "$1" = "--notify-success" ]; then
            send_discord_notification \
                "All Containers Up to Date" \
                "Checked $total_containers containers - all are running the latest versions." \
                "system" \
                "3066993"  # Green color
        fi
    fi
}

# Setup shared variables through interactive prompts
setup_shared_variables() {
    print_info "Setting up shared variables for all services..."
    echo ""
    
    # Discord Webhook
    echo "Discord Notifications:"
    echo "A Discord webhook URL allows all services to send notifications to your Discord server."
    echo "This includes updates, errors, processing completion, etc."
    echo ""
    read -p "Discord webhook URL [leave blank to skip]: " discord_webhook
    
    if [ -n "$discord_webhook" ]; then
        echo "DISCORD_WEBHOOK_URL=$discord_webhook" >> "$PROJECT_DIR/.env"
        
        echo ""
        read -p "Notification title prefix [Surge]: " title_prefix
        echo "NOTIFICATION_TITLE_PREFIX=${title_prefix:-Surge}" >> "$PROJECT_DIR/.env"
        
        # Test the webhook
        print_info "Testing Discord webhook..."
        DISCORD_WEBHOOK_URL="$discord_webhook"
        NOTIFICATION_TITLE_PREFIX="${title_prefix:-Surge}"
        
        send_discord_notification \
            "Webhook Test" \
            "Discord notifications have been successfully configured for Surge!" \
            "system" \
            "3066993"
            
        print_success "Discord webhook configured and tested"
    fi
    
    # TMDB API Key
    echo ""
    echo "TMDB API Key:"
    echo "Required for metadata and poster downloads in Kometa, Posterizarr, and Scanly."
    echo "Get your free API key at: https://www.themoviedb.org/settings/api"
    echo ""
    read -p "TMDB API Key [leave blank to skip]: " tmdb_key
    
    if [ -n "$tmdb_key" ]; then
        echo "TMDB_API_KEY=$tmdb_key" >> "$PROJECT_DIR/.env"
        print_success "TMDB API key configured"
    fi
    
    # Trakt Integration
    echo ""
    echo "Trakt Integration:"
    echo "Optional integration for tracking and list management."
    echo "Get your API credentials at: https://trakt.tv/oauth/applications"
    echo ""
    read -p "Trakt Client ID [leave blank to skip]: " trakt_id
    
    if [ -n "$trakt_id" ]; then
        echo "TRAKT_CLIENT_ID=$trakt_id" >> "$PROJECT_DIR/.env"
        
        read -p "Trakt Client Secret: " trakt_secret
        echo "TRAKT_CLIENT_SECRET=$trakt_secret" >> "$PROJECT_DIR/.env"
        
        print_success "Trakt integration configured"
    fi
    
    echo ""
    print_success "Shared variables setup complete"
    echo ""
    print_info "These settings will be automatically applied to all relevant services."
    print_info "You can run './surge config update' anytime to propagate changes."
}

# Configure notification preferences
configure_notification_preferences() {
    print_step "🔔 Configuring Discord Notification Preferences..."
    
    if [ -z "$DISCORD_WEBHOOK_URL" ]; then
        print_warning "No Discord webhook configured. Set up webhook first with './surge config setup'"
        return 1
    fi
    
    echo ""
    echo "Current notification settings:"
    echo "  Container Updates: ${DISCORD_NOTIFY_UPDATES:-false}"
    echo "  Asset Processing: ${DISCORD_NOTIFY_PROCESSING:-false}"
    echo "  Error Alerts: ${DISCORD_NOTIFY_ERRORS:-false}"
    echo "  Media Events: ${DISCORD_NOTIFY_MEDIA:-false}"
    echo "  System Status: ${DISCORD_NOTIFY_SYSTEM:-false}"
    echo ""
    
    read -p "Configure notification preferences? [Y/n]: " configure_prefs
    
    if [[ "$configure_prefs" =~ ^[Nn]$ ]]; then
        return 0
    fi
    
    # Update notification preferences in .env file
    echo ""
    read -p "Enable container update notifications? [Y/n]: " enable_updates
    DISCORD_NOTIFY_UPDATES=$([[ "$enable_updates" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    read -p "Enable asset processing notifications? [Y/n]: " enable_processing
    DISCORD_NOTIFY_PROCESSING=$([[ "$enable_processing" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    read -p "Enable error alert notifications? [Y/n]: " enable_errors
    DISCORD_NOTIFY_ERRORS=$([[ "$enable_errors" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    read -p "Enable media event notifications (via Tautulli)? [y/N]: " enable_media
    DISCORD_NOTIFY_MEDIA=$([[ "$enable_media" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    read -p "Enable system status notifications? [y/N]: " enable_system
    DISCORD_NOTIFY_SYSTEM=$([[ "$enable_system" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    # Update .env file
    if [ -f "$PROJECT_DIR/.env" ]; then
        # Create temporary file for updates
        local temp_file=$(mktemp)
        
        # Update or add notification preferences
        grep -v "^DISCORD_NOTIFY_" "$PROJECT_DIR/.env" > "$temp_file"
        cat >> "$temp_file" << EOF

# DISCORD NOTIFICATION PREFERENCES
DISCORD_NOTIFY_UPDATES=$DISCORD_NOTIFY_UPDATES
DISCORD_NOTIFY_PROCESSING=$DISCORD_NOTIFY_PROCESSING
DISCORD_NOTIFY_ERRORS=$DISCORD_NOTIFY_ERRORS
DISCORD_NOTIFY_MEDIA=$DISCORD_NOTIFY_MEDIA
DISCORD_NOTIFY_SYSTEM=$DISCORD_NOTIFY_SYSTEM
EOF
        
        mv "$temp_file" "$PROJECT_DIR/.env"
        print_success "Notification preferences updated in .env file"
        
        # Propagate changes to service configs
        propagate_shared_config
    else
        print_error "No .env file found"
        return 1
    fi
}

# Main function
main() {
    case "${1:-help}" in
        "propagate"|"update")
            propagate_shared_config
            ;;
        "setup")
            setup_shared_variables
            propagate_shared_config
            ;;
        "notifications"|"notify")
            configure_notification_preferences
            ;;
        "check-updates")
            check_and_notify_updates "$2"
            ;;
        "test-webhook")
            if [ -f "$PROJECT_DIR/.env" ]; then
                source "$PROJECT_DIR/.env"
            fi
            send_discord_notification \
                "Webhook Test" \
                "This is a test notification from Surge shared configuration system." \
                "system" \
                "3447003"
            print_success "Test notification sent"
            ;;
        "help"|*)
            echo "Surge Shared Configuration Management"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  setup                      Setup shared variables (Discord, TMDB, Trakt)"
            echo "  propagate|update           Update all service configs with shared variables"
            echo "  notifications|notify       Configure Discord notification preferences"
            echo "  check-updates              Check for container updates and notify"
            echo "  test-webhook               Send test Discord notification"
            echo "  help                       Show this help message"
            echo ""
            ;;
    esac
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
