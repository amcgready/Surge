#!/bin/bash

# ===========================================
#!/bin/bash

# ===========================================
# Surge First-Time Setup Script
# Unified media management container setup
# Version: 2.0 - Auto/Custom Installation Modes

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
DARK_BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    printf "\n"
    printf "\033[0;36m  ███████╗██╗   ██╗██████╗  ██████╗ \033[38;5;32m███████╗\033[0m\n"
    printf "\033[0;36m  ██╔════╝██║   ██║██╔══██╗\033[38;5;32m██╔════╝\033[0;36m ██╔════╝\033[0m\n"
    printf "\033[0;36m  ███████╗██║   ██║\033[38;5;32m██████╔╝██║  ███╗\033[0;36m█████╗\033[0m\n"
    printf "\033[38;5;32m  ╚════██║██║   ██║██╔══██╗██║   ██║\033[0;36m██╔══╝\033[0m\n"
    printf "\033[38;5;32m  ███████║╚██████╔╝██║  ██║╚██████╔╝\033[0;36m███████╗\033[0m\n"
    printf "\033[38;5;32m  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ \033[0;36m╚══════╝\033[0m\n"
    printf "\n"
    printf "  🌊 First Time Setup Wizard\n"
    printf "\n"
}

# Check for help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_banner
    echo "Surge First-Time Setup Script"
    echo ""
    echo "USAGE:"
    echo "  ./scripts/first-time-setup.sh [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --help, -h         Show this help message"
    echo "  --reconfigure      Reconfigure existing installation"
    echo "  --auto            Skip installation type selection and use auto mode"
    echo "  --custom          Skip installation type selection and use custom mode"
    echo ""
    echo "INSTALLATION MODES:"
    echo "  Auto Install      - Quick setup with sensible defaults"
    echo "                     ✅ Full stack deployment"
    echo "                     ✅ Minimal questions (media server, storage)"
    echo "                     ✅ Auto-detected user IDs and timezone"
    echo "                     ✅ Perfect for new users"
    echo ""
    echo "  Custom Install    - Complete control over configuration"
    echo "                     🔧 Choose deployment type (full/minimal/custom)"
    echo "                     🔧 Select individual services"
    echo "                     🔧 Configure all ports and settings"
    echo "                     🔧 Perfect for power users"
    echo ""
    echo "FEATURES:"
    echo "  • Auto-detection of configuration updates"
    echo "  • 'New Variable Detected' alerts for service updates"
    echo "  • Backup and merge existing configurations"
    echo "  • 17+ integrated media management services"
    echo "  • Automatic updates with Watchtower"
    echo "  • Scheduled asset processing pipeline"
    echo ""
    echo "EXAMPLES:"
    echo "  ./scripts/first-time-setup.sh"
    echo "  ./scripts/first-time-setup.sh --auto"
    echo "  ./scripts/first-time-setup.sh --reconfigure"
    echo ""
    exit 0
fi
# ===========================================

set -e

# Colors for output
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Check if this is first run
check_first_run() {
    if [ -f "$PROJECT_DIR/.surge_initialized" ]; then
        print_info "Surge has already been initialized"
        echo "Run './surge deploy <media-server>' to start services"
        echo "Run './surge setup' to reconfigure"
        exit 0
    fi
}

# Choose installation type
choose_install_type() {
    print_step "Choose your installation type..."
    echo ""
    echo "🚀 Surge Installation Options:"
    echo ""
    echo "1) Auto Install (Recommended)"
    echo "   ✅ Quick setup with sensible defaults"
    echo "   ✅ Only asks for essential choices (media server, storage)"
    echo "   ✅ Full stack deployment with all features"
    echo "   ✅ Perfect for most users"
    echo ""
    echo "2) Custom Install (Advanced)"
    echo "   ✅ Complete control over every setting"
    echo "   ✅ Choose specific services to deploy"
    echo "   ✅ Configure all environment variables"
    echo "   ✅ Perfect for power users"
    echo ""
    read -p "Enter choice (1-2): " install_choice
    
    case $install_choice in
        1) INSTALL_TYPE="auto" ;;
        2) INSTALL_TYPE="custom" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
    
    echo ""
    print_success "Selected: $([ "$INSTALL_TYPE" = "auto" ] && echo "Auto Install" || echo "Custom Install")"
}

# Auto installation - minimal questions
gather_auto_preferences() {
    print_step "🚀 Auto Installation Setup"
    echo ""
    print_info "This will deploy the full Surge stack with optimal defaults."
    echo "We'll only ask for the essentials!"
    echo ""
    
    # Media server choice
    echo "Choose your media server:"
    echo "1) Plex Media Server (Premium)"
    echo "2) Jellyfin (Free & Open Source)" 
    echo "3) Emby (Feature-rich)"
    echo ""
    read -p "Enter choice (1-3): " media_choice
    
    case $media_choice in
        1) MEDIA_SERVER="plex" ;;
        2) MEDIA_SERVER="jellyfin" ;;
        3) MEDIA_SERVER="emby" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
    
    # Storage location (simplified)
    echo ""
    print_info "Storage Configuration"
    echo "Where should Surge store your media and configurations?"
    echo "Default: /opt/surge (recommended for most users)"
    read -p "Storage path [/opt/surge]: " storage_path
    STORAGE_PATH=${storage_path:-/opt/surge}
    
    # Auto-detect user IDs
    PUID=$(id -u)
    PGID=$(id -g)
    print_info "Using your current user ID: $PUID, group ID: $PGID"
    
    # Auto-detect timezone
    TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "America/New_York")
    print_info "Using detected timezone: $TIMEZONE"
    
    # Optional Discord webhook for notifications
    echo ""
    print_info "🔔 Discord Notifications (Optional)"
    echo "Want to receive notifications about updates and processing?"
    read -p "Discord webhook URL [leave blank to skip]: " discord_webhook
    DISCORD_WEBHOOK_URL=${discord_webhook:-}
    NOTIFICATION_TITLE_PREFIX="Surge"
    
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        # Auto mode enables most notifications by default
        DISCORD_NOTIFY_UPDATES="true"
        DISCORD_NOTIFY_PROCESSING="true"
        DISCORD_NOTIFY_ERRORS="true"
        DISCORD_NOTIFY_MEDIA="false"  # Keep media events off by default
        DISCORD_NOTIFY_SYSTEM="false"
    else
        DISCORD_NOTIFY_UPDATES="false"
        DISCORD_NOTIFY_PROCESSING="false"
        DISCORD_NOTIFY_ERRORS="false"
        DISCORD_NOTIFY_MEDIA="false"
        DISCORD_NOTIFY_SYSTEM="false"
    fi
    
    # Auto settings for full stack
    ENABLE_BAZARR="true"
    ENABLE_PROWLARR="true"
    ENABLE_NZBGET="true"
    ENABLE_ZILEAN="false"
    ENABLE_WATCHTOWER="true"
    ENABLE_SCHEDULER="true"
    DEPLOYMENT_TYPE="full"
    
    print_success "Auto configuration complete! Deploying full stack with all features."
}

# Custom installation - detailed questions
gather_custom_preferences() {
    print_step "🔧 Custom Installation Setup"
    echo ""
    print_info "Complete control over your Surge deployment."
    echo "We'll walk through every configuration option."
    echo ""
    
    # Media server choice
    echo "Choose your media server:"
    echo "1) Plex Media Server (Premium)"
    echo "2) Jellyfin (Free & Open Source)"
    echo "3) Emby (Feature-rich)"
    echo ""
    read -p "Enter choice (1-3): " media_choice
    
    case $media_choice in
        1) MEDIA_SERVER="plex" ;;
        2) MEDIA_SERVER="jellyfin" ;;
        3) MEDIA_SERVER="emby" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
    
    # Deployment type
    echo ""
    echo "Choose deployment type:"
    echo "1) Full Stack - All services and features"
    echo "2) Minimal - Core services only (media server + automation)"
    echo "3) Custom - Choose specific services"
    read -p "Enter choice (1-3): " deploy_choice
    
    case $deploy_choice in
        1) DEPLOYMENT_TYPE="full" ;;
        2) DEPLOYMENT_TYPE="minimal" ;;
        3) DEPLOYMENT_TYPE="custom" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
    
    # Storage location
    echo ""
    print_info "Storage Configuration"
    echo "Where would you like to store your media and configuration?"
    echo "Default: /opt/surge (recommended)"
    read -p "Storage path [/opt/surge]: " storage_path
    STORAGE_PATH=${storage_path:-/opt/surge}
    
    # User/Group IDs
    echo ""
    print_info "User Configuration"
    echo "Current user ID: $(id -u)"
    echo "Current group ID: $(id -g)"
    read -p "Use current user/group IDs? [Y/n]: " use_current_ids
    
    if [[ "$use_current_ids" =~ ^[Nn]$ ]]; then
        read -p "Enter user ID: " PUID
        read -p "Enter group ID: " PGID
    else
        PUID=$(id -u)
        PGID=$(id -g)
    fi
    
    # Timezone
    echo ""
    print_info "Timezone Configuration"
    echo "Current timezone: $(timedatectl show --property=Timezone --value 2>/dev/null || echo "Unknown")"
    read -p "Enter timezone [America/New_York]: " timezone
    TIMEZONE=${timezone:-America/New_York}
    
    # Port Configuration
    echo ""
    print_info "Network Port Configuration"
    read -p "Homepage port [3000]: " homepage_port
    HOMEPAGE_PORT=${homepage_port:-3000}
    
    read -p "Radarr port [7878]: " radarr_port
    RADARR_PORT=${radarr_port:-7878}
    
    read -p "Sonarr port [8989]: " sonarr_port
    SONARR_PORT=${sonarr_port:-8989}
    
    case $MEDIA_SERVER in
        plex)
            read -p "Plex port [32400]: " media_port
            PLEX_PORT=${media_port:-32400}
            ;;
        emby|jellyfin)
            read -p "$MEDIA_SERVER port [8096]: " media_port
            if [ "$MEDIA_SERVER" = "emby" ]; then
                EMBY_PORT=${media_port:-8096}
            else
                JELLYFIN_PORT=${media_port:-8096}
            fi
            ;;
    esac
    
    # Service Selection based on deployment type
    if [ "$DEPLOYMENT_TYPE" = "custom" ]; then
        echo ""
        print_info "Service Selection"
        echo "Choose which services to enable:"
        
        read -p "Enable Bazarr (subtitles)? [Y/n]: " enable_bazarr
        ENABLE_BAZARR=$([[ "$enable_bazarr" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable Prowlarr (indexer manager)? [Y/n]: " enable_prowlarr
        ENABLE_PROWLARR=$([[ "$enable_prowlarr" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable NZBGet (Usenet downloader)? [Y/n]: " enable_nzbget
        ENABLE_NZBGET=$([[ "$enable_nzbget" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable RDT-Client (Real-Debrid)? [y/N]: " enable_rdt
        ENABLE_RDT_CLIENT=$([[ "$enable_rdt" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        
        read -p "Enable Zilean (DMM content search)? [y/N]: " enable_zilean
        ENABLE_ZILEAN=$([[ "$enable_zilean" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        
        read -p "Enable Kometa (metadata manager)? [Y/n]: " enable_kometa
        ENABLE_KOMETA=$([[ "$enable_kometa" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable Posterizarr (poster management)? [Y/n]: " enable_posterizarr
        ENABLE_POSTERIZARR=$([[ "$enable_posterizarr" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable Overseerr (request management)? [Y/n]: " enable_overseerr
        ENABLE_OVERSEERR=$([[ "$enable_overseerr" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable Tautulli (monitoring)? [Y/n]: " enable_tautulli
        ENABLE_TAUTULLI=$([[ "$enable_tautulli" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable Scanly (media scanner)? [Y/n]: " enable_scanly
        ENABLE_SCANLY=$([[ "$enable_scanly" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        
        read -p "Enable CineSync? [y/N]: " enable_cinesync
        ENABLE_CINESYNC=$([[ "$enable_cinesync" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        
        read -p "Enable Placeholdarr? [y/N]: " enable_placeholdarr
        ENABLE_PLACEHOLDARR=$([[ "$enable_placeholdarr" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        
    elif [ "$DEPLOYMENT_TYPE" = "minimal" ]; then
        # Minimal deployment
        ENABLE_BAZARR="false"
        ENABLE_PROWLARR="true"
        ENABLE_NZBGET="true"
        ENABLE_RDT_CLIENT="false"
        ENABLE_ZILEAN="false"
        ENABLE_KOMETA="false"
        ENABLE_POSTERIZARR="false"
        ENABLE_OVERSEERR="true"
        ENABLE_TAUTULLI="true"
        ENABLE_SCANLY="false"
        ENABLE_CINESYNC="false"
        ENABLE_PLACEHOLDARR="false"
    else
        # Full deployment
        ENABLE_BAZARR="true"
        ENABLE_PROWLARR="true"
        ENABLE_NZBGET="true"
        ENABLE_RDT_CLIENT="false"
        ENABLE_ZILEAN="false"
        ENABLE_KOMETA="true"
        ENABLE_POSTERIZARR="true"
        ENABLE_OVERSEERR="true"
        ENABLE_TAUTULLI="true"
        ENABLE_SCANLY="true"
        ENABLE_CINESYNC="false"
        ENABLE_PLACEHOLDARR="false"
    fi
    
    # Automation Configuration
    echo ""
    print_info "Automation Configuration"
    
    read -p "Enable automatic updates (Watchtower)? [Y/n]: " enable_watchtower
    ENABLE_WATCHTOWER=$([[ "$enable_watchtower" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    if [ "$ENABLE_WATCHTOWER" = "true" ]; then
        read -p "Update check interval in seconds [86400 (24h)]: " watchtower_interval
        WATCHTOWER_INTERVAL=${watchtower_interval:-86400}
    fi
    
    read -p "Enable scheduled asset processing? [Y/n]: " enable_scheduler
    ENABLE_SCHEDULER=$([[ "$enable_scheduler" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    if [ "$ENABLE_SCHEDULER" = "true" ]; then
        echo "Asset processing schedule (cron format):"
        echo "  0 2 * * * = Daily at 2 AM"
        echo "  0 */6 * * * = Every 6 hours"
        read -p "Schedule [0 2 * * *]: " asset_schedule
        ASSET_PROCESSING_SCHEDULE=${asset_schedule:-"0 2 * * *"}
    fi
    
    # API Keys and External Services
    echo ""
    print_info "External Services & Notifications"
    
    # Discord Webhook
    echo ""
    echo "🔔 Discord Notifications (Recommended)"
    echo "Configure a Discord webhook to receive notifications from all services:"
    echo "• Container updates available"
    echo "• Processing completion (Kometa, Scanly, etc.)"
    echo "• Error alerts"
    echo "• System status updates"
    echo ""
    read -p "Discord webhook URL [leave blank to skip]: " discord_webhook
    DISCORD_WEBHOOK_URL=${discord_webhook:-}
    
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        read -p "Notification title prefix [Surge]: " title_prefix
        NOTIFICATION_TITLE_PREFIX=${title_prefix:-Surge}
        
        echo ""
        print_info "📋 Notification Preferences"
        echo "Choose which types of notifications to receive:"
        
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
    else
        # Set defaults when no Discord webhook
        DISCORD_NOTIFY_UPDATES="false"
        DISCORD_NOTIFY_PROCESSING="false"
        DISCORD_NOTIFY_ERRORS="false"
        DISCORD_NOTIFY_MEDIA="false"
        DISCORD_NOTIFY_SYSTEM="false"
    fi
    
    read -p "TMDB API Key (for metadata) [leave blank]: " tmdb_key
    TMDB_API_KEY=${tmdb_key:-}
    
    read -p "Trakt Client ID [leave blank]: " trakt_id
    TRAKT_CLIENT_ID=${trakt_id:-}
    
    if [ -n "$TRAKT_CLIENT_ID" ]; then
        read -p "Trakt Client Secret: " trakt_secret
        TRAKT_CLIENT_SECRET=${trakt_secret:-}
    fi
    
    # Download Client Configuration
    if [ "$ENABLE_NZBGET" = "true" ]; then
        echo ""
        print_info "NZBGet Configuration"
        read -p "NZBGet username [admin]: " nzbget_user
        NZBGET_USER=${nzbget_user:-admin}
        
        read -p "NZBGet password [tegbzn6789]: " nzbget_pass
        NZBGET_PASS=${nzbget_pass:-tegbzn6789}
    fi
    
    if [ "$ENABLE_RDT_CLIENT" = "true" ]; then
        echo ""
        print_info "Real-Debrid Configuration"
        read -p "Real-Debrid API Token: " rd_token
        RD_API_TOKEN=${rd_token:-}
        
        read -p "Real-Debrid Username: " rd_username
        RD_USERNAME=${rd_username:-}
    fi
}

# Create configuration file
create_config() {
    print_step "Creating configuration file..."
    
    cat > "$PROJECT_DIR/.env" << EOF
# ===========================================
# SURGE CONFIGURATION - Generated $(date)
# ===========================================

# GENERAL CONFIGURATION
TZ=$TIMEZONE
PUID=$PUID
PGID=$PGID

# STORAGE PATHS
DATA_ROOT=$STORAGE_PATH
MOVIES_DIR=\${DATA_ROOT}/media/movies
TV_SHOWS_DIR=\${DATA_ROOT}/media/tv
DOWNLOADS_DIR=\${DATA_ROOT}/downloads
CONFIG_DIR=\${DATA_ROOT}/config

# MEDIA SERVER SELECTION
MEDIA_SERVER=$MEDIA_SERVER

# SERVICE CONFIGURATION
ENABLE_BAZARR=${ENABLE_BAZARR:-true}
ENABLE_PROWLARR=${ENABLE_PROWLARR:-true}
ENABLE_NZBGET=${ENABLE_NZBGET:-true}
ENABLE_RDT_CLIENT=${ENABLE_RDT_CLIENT:-false}
ENABLE_ZILEAN=${ENABLE_ZILEAN:-false}
ENABLE_KOMETA=${ENABLE_KOMETA:-true}
ENABLE_POSTERIZARR=${ENABLE_POSTERIZARR:-true}
ENABLE_OVERSEERR=${ENABLE_OVERSEERR:-true}
ENABLE_TAUTULLI=${ENABLE_TAUTULLI:-true}
ENABLE_SCANLY=${ENABLE_SCANLY:-true}
ENABLE_CINESYNC=${ENABLE_CINESYNC:-false}
ENABLE_PLACEHOLDARR=${ENABLE_PLACEHOLDARR:-false}
ENABLE_WATCHTOWER=${ENABLE_WATCHTOWER:-true}
ENABLE_SCHEDULER=${ENABLE_SCHEDULER:-true}

# NETWORK PORTS
HOMEPAGE_PORT=${HOMEPAGE_PORT:-3000}
RADARR_PORT=${RADARR_PORT:-7878}
SONARR_PORT=${SONARR_PORT:-8989}
PROWLARR_PORT=9696
BAZARR_PORT=6767
NZBGET_PORT=6789
ZILEAN_PORT=8182
TAUTULLI_PORT=8181
OVERSEERR_PORT=5055
SCANLY_PORT=8183
RDT_CLIENT_PORT=6500
KOMETA_PORT=5556
PLEX_PORT=${PLEX_PORT:-32400}
EMBY_PORT=${EMBY_PORT:-8096}
JELLYFIN_PORT=${JELLYFIN_PORT:-8096}

# AUTOMATION
WATCHTOWER_INTERVAL=${WATCHTOWER_INTERVAL:-86400}
ASSET_PROCESSING_SCHEDULE=${ASSET_PROCESSING_SCHEDULE:-"0 2 * * *"}

# EXTERNAL SERVICES (OPTIONAL)
TMDB_API_KEY=${TMDB_API_KEY:-}
TRAKT_CLIENT_ID=${TRAKT_CLIENT_ID:-}
TRAKT_CLIENT_SECRET=${TRAKT_CLIENT_SECRET:-}

# NOTIFICATIONS & WEBHOOKS
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL:-}
NOTIFICATION_TITLE_PREFIX=${NOTIFICATION_TITLE_PREFIX:-Surge}
DISCORD_NOTIFY_UPDATES=${DISCORD_NOTIFY_UPDATES:-false}
DISCORD_NOTIFY_PROCESSING=${DISCORD_NOTIFY_PROCESSING:-false}
DISCORD_NOTIFY_ERRORS=${DISCORD_NOTIFY_ERRORS:-false}
DISCORD_NOTIFY_MEDIA=${DISCORD_NOTIFY_MEDIA:-false}
DISCORD_NOTIFY_SYSTEM=${DISCORD_NOTIFY_SYSTEM:-false}

# DOWNLOAD CLIENT SETTINGS
NZBGET_USER=${NZBGET_USER:-admin}
NZBGET_PASS=${NZBGET_PASS:-tegbzn6789}
RD_API_TOKEN=${RD_API_TOKEN:-}
RD_USERNAME=${RD_USERNAME:-}

# DEPLOYMENT TYPE
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-full}
INSTALL_TYPE=${INSTALL_TYPE:-auto}

# GENERATED TIMESTAMP
CONFIG_GENERATED=$(date '+%Y-%m-%d %H:%M:%S')
CONFIG_VERSION=1.0
EOF

    print_success "Configuration file created"
    
    # Propagate shared configuration to all services
    if [ -f "$PROJECT_DIR/scripts/shared-config.sh" ]; then
        print_step "Configuring individual services..."
        "$PROJECT_DIR/scripts/shared-config.sh" propagate
    fi
}

# Create directory structure
create_directories() {
    print_step "Creating directory structure..."
    
    # Create directories with proper permissions
    sudo mkdir -p "$STORAGE_PATH"/{media/{movies,tv,music},downloads,config,logs}
    sudo chown -R "$PUID:$PGID" "$STORAGE_PATH"
    
    print_success "Directory structure created at $STORAGE_PATH"
}

# Create initial service configurations
create_service_configs() {
    print_step "Creating initial service configurations..."
    
    # Create Kometa config template
    mkdir -p "$PROJECT_DIR/initial-configs"
    
    cat > "$PROJECT_DIR/initial-configs/kometa-config.yml" << 'EOF'
libraries:
  Movies:
    metadata_path:
      - pmm: basic
      - pmm: imdb
    operations:
      mass_critic_rating_update: tmdb
      mass_audience_rating_update: tmdb

  TV Shows:
    metadata_path:
      - pmm: basic
      - pmm: imdb
    operations:
      mass_critic_rating_update: tmdb
      mass_audience_rating_update: tmdb

plex:
  url: http://surge-plex:32400
  token: PLEX_TOKEN_HERE

tmdb:
  apikey: TMDB_API_KEY_HERE
  language: en

settings:
  cache: true
  asset_directory: /assets
  save_missing: true
EOF

    print_success "Service configurations created"
}

# Show next steps
show_next_steps() {
    echo ""
    print_success "🎉 Surge setup completed!"
    echo ""
    print_info "Next steps:"
    echo ""
    echo "1. Deploy Surge:"
    echo "   ./surge deploy $MEDIA_SERVER"
    echo ""
    echo "2. Access your services:"
    echo "   - Homepage Dashboard: http://localhost:3000"
    
    case $MEDIA_SERVER in
        plex)
            echo "   - Plex Media Server: http://localhost:32400/web"
            ;;
        emby)
            echo "   - Emby Server: http://localhost:8096"
            ;;
        jellyfin)
            echo "   - Jellyfin Server: http://localhost:8096"
            ;;
    esac
    
    echo "   - Radarr: http://localhost:7878"
    echo "   - Sonarr: http://localhost:8989"
    
    if [ "$ENABLE_BAZARR" = "true" ]; then
        echo "   - Bazarr: http://localhost:6767"
    fi
    
    if [ "$ENABLE_NZBGET" = "true" ]; then
        echo "   - NZBGet: http://localhost:6789"
    fi
    
    echo ""
    echo "3. Command-line tools:"
    echo "   - Run Scanly: ./surge exec scanly"
    echo "   - Asset processing: ./surge process sequence"
    echo "   - View logs: ./surge logs"
    echo ""
    echo "4. Configuration:"
    echo "   - Edit .env file for advanced settings"
    echo "   - Get TMDB API key: https://www.themoviedb.org/settings/api"
    echo "   - Configure indexers in Radarr/Sonarr"
    echo ""
    
    print_warning "Important: Configure your download clients and indexers after deployment!"
}

# Mark as initialized
mark_initialized() {
    echo "$(date): Surge initialized with $MEDIA_SERVER" > "$PROJECT_DIR/.surge_initialized"
}

# Detect new variables in updated containers
detect_new_variables() {
    print_step "🔍 Checking for configuration updates..."
    
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        return 0
    fi
    
    # Get current config version
    current_version=$(grep "CONFIG_VERSION=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "0")
    expected_version="1.0"
    
    if [ "$current_version" != "$expected_version" ]; then
        echo ""
        print_warning "🆕 New Variable Detected!"
        echo ""
        echo "Your Surge configuration is outdated. New services or features"
        echo "may have been added that require additional configuration."
        echo ""
        echo "Current config version: $current_version"
        echo "Expected version: $expected_version"
        echo ""
        read -p "Would you like to update your configuration? [Y/n]: " update_config
        
        if [[ ! "$update_config" =~ ^[Nn]$ ]]; then
            echo ""
            print_info "Configuration update options:"
            echo "1) Merge new variables with current settings (recommended)"
            echo "2) Backup current config and run full setup again"
            echo "3) Skip update (not recommended)"
            read -p "Choose option (1-3): " update_choice
            
            case $update_choice in
                1)
                    backup_and_merge_config
                    ;;
                2)
                    cp "$PROJECT_DIR/.env" "$PROJECT_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"
                    print_info "Current config backed up. Running full setup..."
                    choose_install_type
                    if [ "$INSTALL_TYPE" = "auto" ]; then
                        gather_auto_preferences
                    else
                        gather_custom_preferences
                    fi
                    create_config
                    ;;
                3)
                    print_warning "Skipping configuration update. Some features may not work correctly."
                    ;;
                *)
                    print_error "Invalid choice"
                    return 1
                    ;;
            esac
        fi
    fi
}

# Backup and merge configuration
backup_and_merge_config() {
    print_step "📦 Backing up and merging configuration..."
    
    # Create backup
    backup_file="$PROJECT_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$PROJECT_DIR/.env" "$backup_file"
    print_success "Backup created: $backup_file"
    
    # Load existing values
    source "$PROJECT_DIR/.env"
    
    # Create updated config with existing values where possible
    create_config
    
    print_success "Configuration updated with new variables while preserving your settings."
    print_info "Please review the updated .env file and adjust any new settings as needed."
}

# Main setup function
main() {
    print_banner
    
    # Check if already initialized
    check_first_run
    
    # Check for configuration updates if already exists
    detect_new_variables
    
    # If no config exists or user chose to reconfigure, gather preferences
    if [ ! -f "$PROJECT_DIR/.env" ] || [ "$1" = "--reconfigure" ]; then
        # Handle command line installation type selection
        if [ "$1" = "--auto" ]; then
            INSTALL_TYPE="auto"
        elif [ "$1" = "--custom" ]; then
            INSTALL_TYPE="custom"
        else
            # Choose installation type interactively
            choose_install_type
        fi
        
        # Gather preferences based on chosen type
        if [ "$INSTALL_TYPE" = "auto" ]; then
            gather_auto_preferences
        else
            gather_custom_preferences
        fi
        
        # Create configuration
        create_config
    fi
    
    # Create directories
    create_directories
    
    # Create service configs
    create_service_configs
    
    # Mark as initialized
    mark_initialized
    
    # Show next steps
    show_next_steps
    
    # Send welcome Discord notification if webhook is configured
    if [ -n "$DISCORD_WEBHOOK_URL" ] && [ -f "$PROJECT_DIR/scripts/shared-config.sh" ]; then
        print_step "Sending setup completion notification..."
        
        # Source the .env to get variables
        source "$PROJECT_DIR/.env"
        
        # Test webhook with setup completion message
        "$PROJECT_DIR/scripts/shared-config.sh" test-webhook
    fi
}

# Run main function
main "$@"
