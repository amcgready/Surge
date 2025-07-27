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
    # Auto-detect imagemaid variables
    PLEX_CONFIG_DIR="${DATA_ROOT}/config/plex"
    IMAGEMAID_MODE="remove"
    # Try to auto-detect Plex token from Kometa config if available
    if [ -f "$PROJECT_DIR/initial-configs/kometa-config.yml" ]; then
        PLEX_TOKEN=$(grep 'token:' "$PROJECT_DIR/initial-configs/kometa-config.yml" | awk '{print $2}')
    fi
    PLEX_TOKEN=${PLEX_TOKEN:-changeme}
    PLEX_URL="http://localhost:${PLEX_PORT:-32400}"
    # Append imagemaid variables to .env
    echo "" >> "$PROJECT_DIR/.env"
    echo "# ImageMaid Integration" >> "$PROJECT_DIR/.env"
    echo "IMAGEMAID_MODE=$IMAGEMAID_MODE" >> "$PROJECT_DIR/.env"
    echo "PLEX_PATH=/plex" >> "$PROJECT_DIR/.env"
    echo "PLEX_URL=$PLEX_URL" >> "$PROJECT_DIR/.env"
    echo "PLEX_TOKEN=$PLEX_TOKEN" >> "$PROJECT_DIR/.env"
    echo "PLEX_CONFIG_DIR=$PLEX_CONFIG_DIR" >> "$PROJECT_DIR/.env"
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
    read -p "Discord webhook URL (optional): " discord_webhook
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
    ENABLE_ZILEAN="true"  # Always enable Zilean
    ENABLE_CLI_DEBRID="false"
    ENABLE_DECYPHARR="false"
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
    detected_timezone=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "America/New_York")
    echo "Current timezone: $detected_timezone"
    read -p "Enter timezone [$detected_timezone]: " timezone
    TIMEZONE=${timezone:-$detected_timezone}
    
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
        
        ENABLE_ZILEAN="true"  # Always enable Zilean
        
        read -p "Enable cli_debrid (debrid CLI management)? [y/N]: " enable_cli_debrid
        ENABLE_CLI_DEBRID=$([[ "$enable_cli_debrid" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        
        read -p "Enable Decypharr (automated decryption)? [y/N]: " enable_decypharr
        ENABLE_DECYPHARR=$([[ "$enable_decypharr" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        
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
        ENABLE_ZILEAN="true"  # Always enable Zilean
        ENABLE_CLI_DEBRID="false"
        ENABLE_DECYPHARR="false"
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
        ENABLE_ZILEAN="true"  # Always enable Zilean
        ENABLE_CLI_DEBRID="false"
        ENABLE_DECYPHARR="false"
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
    read -p "Discord webhook URL (optional): " discord_webhook
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
    
    read -p "TMDB API Key (for metadata) (optional): " tmdb_key
    TMDB_API_KEY=${tmdb_key:-}

    read -p "Trakt Client ID (optional): " trakt_id
    TRAKT_CLIENT_ID=${trakt_id:-}

    if [ -n "$TRAKT_CLIENT_ID" ]; then
        read -p "Trakt Client Secret (optional): " trakt_secret
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
    
    # Enhanced API Keys for comprehensive setup
    echo ""
    print_info "Additional API Keys (Enhanced Integration)"
    echo "These API keys enable full automation and advanced features:"
    
    if [ "$ENABLE_PROWLARR" = "true" ]; then
        echo ""
        echo "📡 Prowlarr will be auto-configured with:"
        echo "• Torrentio indexer (requires Real-Debrid API key)"
        if [ "$ENABLE_ZILEAN" = "true" ]; then
            echo "• Zilean integration"
        fi
        echo "• Auto-connection to Radarr and Sonarr"
        
        if [ -z "$RD_API_TOKEN" ] && [ "$ENABLE_RDT_CLIENT" != "true" ]; then
            read -p "Real-Debrid API Token (for Torrentio) (optional): " prowlarr_rd_token
            RD_API_TOKEN=${prowlarr_rd_token:-}
        fi
        
        if [ "$ENABLE_CLI_DEBRID" = "true" ]; then
            echo ""
            echo "🔧 cli_debrid Configuration:"
            if [ -z "$RD_API_TOKEN" ]; then
                read -p "Real-Debrid API Token (optional): " rd_token_cli
                RD_API_TOKEN=${rd_token_cli:-}
            fi
            read -p "AllDebrid API Token (optional): " ad_token
            AD_API_TOKEN=${ad_token:-}
            read -p "Premiumize API Token (optional): " pm_token
            PREMIUMIZE_API_TOKEN=${pm_token:-}
        fi
    fi
    
    if [ "$ENABLE_POSTERIZARR" = "true" ]; then
        echo ""
        echo "🎨 Posterizarr Enhanced Configuration:"
        read -p "Fanart.tv API Key (optional): " fanart_key
        FANART_API_KEY=${fanart_key:-}

        read -p "TVDB API Key (optional): " tvdb_key
        TVDB_API_KEY=${tvdb_key:-}
    fi
}

# Create download directories with proper permissions
create_download_directories() {
    print_step "Creating download directories..."
    
    # Create directory structure
    mkdir -p "$STORAGE_PATH/downloads/"{nzbget,rdt-client,completed,incomplete}
    mkdir -p "$STORAGE_PATH/downloads/completed/"{movies,tv}
    mkdir -p "$STORAGE_PATH/downloads/incomplete/"{movies,tv}
    
    # Set proper permissions
    chmod 755 "$STORAGE_PATH/downloads"
    chmod 755 "$STORAGE_PATH/downloads"/*
    
    # Change ownership if running as root
    if [ "$EUID" -eq 0 ]; then
        chown -R "$PUID:$PGID" "$STORAGE_PATH/downloads"
    fi
    
    print_success "Download directories created and configured"
}

# Comprehensive post-deployment configuration
configure_services_post_deployment() {
    print_step "🔧 Configuring service interconnections..."
    
    # Wait for services to start up
    print_info "Waiting for services to initialize..."
    sleep 30
    
    # Configure Prowlarr indexers and connections
    if [ "$ENABLE_PROWLARR" = "true" ]; then
        configure_prowlarr_comprehensive
    fi
    
    # Configure download clients in Radarr/Sonarr
    configure_arr_download_clients
    
    # Configure media server connections
    configure_media_server_connections

    # Configure homepage widgets for all enabled services
    configure_homepage_widgets
    
    print_success "Service configuration completed!"
}
# Generate homepage.yaml widgets for all enabled services
configure_homepage_widgets() {
    print_step "🖥️  Configuring Homepage widgets..."
    local homepage_yaml="$PROJECT_DIR/homepage.yaml"
    echo "services:" > "$homepage_yaml"

    # Homepage dashboard
    echo "  - name: Homepage" >> "$homepage_yaml"
    echo "    url: http://localhost:${HOMEPAGE_PORT:-3000}" >> "$homepage_yaml"

    # Media server
    case "$MEDIA_SERVER" in
        plex)
            echo "  - name: Plex" >> "$homepage_yaml"
            echo "    url: http://localhost:${PLEX_PORT:-32400}/web" >> "$homepage_yaml"
            ;;
        emby)
            echo "  - name: Emby" >> "$homepage_yaml"
            echo "    url: http://localhost:${EMBY_PORT:-8096}" >> "$homepage_yaml"
            ;;
        jellyfin)
            echo "  - name: Jellyfin" >> "$homepage_yaml"
            echo "    url: http://localhost:${JELLYFIN_PORT:-8096}" >> "$homepage_yaml"
            ;;
    esac

    # Core services
    if [ "$ENABLE_PROWLARR" = "true" ]; then
        echo "  - name: Prowlarr" >> "$homepage_yaml"
        echo "    url: http://localhost:9696" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_BAZARR" = "true" ]; then
        echo "  - name: Bazarr" >> "$homepage_yaml"
        echo "    url: http://localhost:6767" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_NZBGET" = "true" ]; then
        echo "  - name: NZBGet" >> "$homepage_yaml"
        echo "    url: http://localhost:6789" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_RDT_CLIENT" = "true" ]; then
        echo "  - name: RDT-Client" >> "$homepage_yaml"
        echo "    url: http://localhost:6500" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_CLI_DEBRID" = "true" ]; then
        echo "  - name: cli_debrid" >> "$homepage_yaml"
        echo "    url: cli" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_DECYPHARR" = "true" ]; then
        echo "  - name: Decypharr" >> "$homepage_yaml"
        echo "    url: http://localhost:8282" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_ZILEAN" = "true" ]; then
        echo "  - name: Zilean" >> "$homepage_yaml"
        echo "    url: http://localhost:8182" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_GAPS" = "true" ]; then
        echo "  - name: GAPS" >> "$homepage_yaml"
        echo "    url: http://localhost:${GAPS_PORT:-8484}" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_OVERSEERR" = "true" ]; then
        echo "  - name: Overseerr" >> "$homepage_yaml"
        echo "    url: http://localhost:5055" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_TAUTULLI" = "true" ]; then
        echo "  - name: Tautulli" >> "$homepage_yaml"
        echo "    url: http://localhost:8181" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_POSTERIZARR" = "true" ]; then
        echo "  - name: Posterizarr" >> "$homepage_yaml"
        echo "    url: http://localhost:9876" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_KOMETA" = "true" ]; then
        echo "  - name: Kometa" >> "$homepage_yaml"
        echo "    url: http://localhost:5556" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_SCANLY" = "true" ]; then
        echo "  - name: Scanly" >> "$homepage_yaml"
        echo "    url: http://localhost:8183" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_CINESYNC" = "true" ]; then
        echo "  - name: CineSync" >> "$homepage_yaml"
        echo "    url: http://localhost:8184" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_PLACEHOLDARR" = "true" ]; then
        echo "  - name: Placeholdarr" >> "$homepage_yaml"
        echo "    url: http://localhost:8185" >> "$homepage_yaml"
    fi

    print_success "Homepage widgets configured in homepage.yaml"
}

# Comprehensive Prowlarr configuration
configure_prowlarr_comprehensive() {
    print_info "🔍 Configuring Prowlarr with indexers and connections..."
    
    # Wait specifically for Prowlarr to be ready
    wait_for_service "prowlarr" "9696" "/api/v1/system/status"
    
    # Get Prowlarr API key
    PROWLARR_API_KEY=$(get_prowlarr_api_key)
    
    if [ -n "$PROWLARR_API_KEY" ]; then
        # Add Torrentio indexer if Real-Debrid token is available
        if [ -n "$RD_API_TOKEN" ]; then
            add_torrentio_indexer
        fi
        
        # Add Zilean indexer if enabled
        if [ "$ENABLE_ZILEAN" = "true" ]; then
            add_zilean_indexer
        fi
        
        # Connect Prowlarr to Radarr and Sonarr
        connect_prowlarr_to_arr_services
    else
        print_warning "Could not retrieve Prowlarr API key - manual configuration required"
    fi
}

# Wait for a service to be ready
wait_for_service() {
    local service=$1
    local port=$2
    local endpoint=${3:-"/"}
    local max_attempts=30
    local attempt=1
    
    print_info "Waiting for $service to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:$port$endpoint" > /dev/null 2>&1; then
            print_success "$service is ready!"
            return 0
        fi
        
        printf "."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    print_warning "$service not ready after $((max_attempts * 5)) seconds"
    return 1
}

# Get Prowlarr API key from config
get_prowlarr_api_key() {
    local config_file="$STORAGE_PATH/config/prowlarr/config.xml"
    local attempt=1
    local max_attempts=12
    
    while [ $attempt -le $max_attempts ]; do
        if [ -f "$config_file" ]; then
            # Extract API key from config.xml
            local api_key=$(grep -o '<ApiKey>[^<]*</ApiKey>' "$config_file" 2>/dev/null | sed 's/<[^>]*>//g')
            if [ -n "$api_key" ] && [ "$api_key" != "$(printf '0%.0s' {1..32})" ]; then
                echo "$api_key"
                return 0
            fi
        fi
        
        sleep 5
        attempt=$((attempt + 1))
    done
    
    return 1
}

# Add Torrentio indexer to Prowlarr
add_torrentio_indexer() {
    print_info "Adding Torrentio indexer to Prowlarr..."
    
    local indexer_data='{
        "enable": true,
        "name": "Torrentio",
        "implementation": "Torrentio",
        "implementationName": "Torrentio",
        "protocol": "torrent",
        "priority": 25,
        "downloadClientId": 0,
        "tags": [],
        "fields": [
            {
                "name": "baseUrl",
                "value": "https://torrentio.strem.fun"
            },
            {
                "name": "apiKey",
                "value": "'$RD_API_TOKEN'"
            },
            {
                "name": "providers",
                "value": "yts,eztv,rarbg,1337x,thepiratebay,kickasstorrents,torrentgalaxy,magnetdl,horriblesubs,nyaasi,tokyotosho,anidex"
            }
        ]
    }'
    
    curl -s -X POST "http://localhost:9696/api/v1/indexer" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $PROWLARR_API_KEY" \
        -d "$indexer_data" > /dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Torrentio indexer added successfully"
    else
        print_warning "Failed to add Torrentio indexer"
    fi
}

# Add Zilean indexer to Prowlarr
add_zilean_indexer() {
    print_info "Adding Zilean indexer to Prowlarr..."
    
    local indexer_data='{
        "enable": true,
        "name": "Zilean",
        "implementation": "Torznab",
        "implementationName": "Generic Torznab",
        "protocol": "torrent",
        "priority": 25,
        "downloadClientId": 0,
        "tags": [],
        "fields": [
            {
                "name": "baseUrl",
                "value": "http://surge-zilean:8182"
            },
            {
                "name": "apiPath",
                "value": "/torznab"
            },
            {
                "name": "categories",
                "value": "5000,5030,5040"
            }
        ]
    }'
    
    curl -s -X POST "http://localhost:9696/api/v1/indexer" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $PROWLARR_API_KEY" \
        -d "$indexer_data" > /dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Zilean indexer added successfully"
    else
        print_warning "Failed to add Zilean indexer"
    fi
}

# Connect Prowlarr to Radarr and Sonarr
connect_prowlarr_to_arr_services() {
    print_info "Connecting Prowlarr to Radarr and Sonarr..."
    
    # Get API keys for Radarr and Sonarr
    local radarr_api_key=$(get_arr_api_key "radarr" "7878")
    local sonarr_api_key=$(get_arr_api_key "sonarr" "8989")
    
    # Add Radarr connection
    if [ -n "$radarr_api_key" ]; then
        add_prowlarr_app_connection "radarr" "$radarr_api_key" "7878"
        add_prowlarr_to_arr "radarr" "7878"
    fi
    
    # Add Sonarr connection  
    if [ -n "$sonarr_api_key" ]; then
        add_prowlarr_app_connection "sonarr" "$sonarr_api_key" "8989"
        add_prowlarr_to_arr "sonarr" "8989"
    fi
}

# Add Prowlarr as an indexer in Sonarr and Radarr
add_prowlarr_to_arr() {
    local service=$1
    local port=$2
    local api_key=$(get_arr_api_key "$service" "$port")
    local prowlarr_api_key=$(get_prowlarr_api_key)
    if [ -n "$api_key" ] && [ -n "$prowlarr_api_key" ]; then
        print_info "Adding Prowlarr as indexer in $service..."
        local indexer_data='{
            "enable": true,
            "name": "Prowlarr",
            "protocol": "torrent",
            "priority": 1,
            "fields": [
                {"name": "baseUrl", "value": "http://surge-prowlarr:9696"},
                {"name": "apiKey", "value": "'$prowlarr_api_key'"}
            ],
            "implementation": "Prowlarr",
            "implementationName": "Prowlarr",
            "configContract": "ProwlarrSettings",
            "tags": []
        }'
        curl -s -X POST "http://localhost:$port/api/v3/indexer" \
            -H "Content-Type: application/json" \
            -H "X-Api-Key: $api_key" \
            -d "$indexer_data" > /dev/null
        if [ $? -eq 0 ]; then
            print_success "Prowlarr indexer added to $service"
        else
            print_warning "Failed to add Prowlarr indexer to $service"
        fi
    fi
}

# Configure download clients in Radarr and Sonarr
configure_arr_download_clients() {
    print_info "Configuring download clients in Radarr and Sonarr..."
    
    # Configure NZBGet if enabled
    if [ "$ENABLE_NZBGET" = "true" ]; then
        configure_nzbget_in_arr "radarr" "7878"
        configure_nzbget_in_arr "sonarr" "8989"
    fi
    
    # Configure RDT-Client if enabled
    if [ "$ENABLE_RDT_CLIENT" = "true" ]; then
        configure_rdt_client_in_arr "radarr" "7878"
        configure_rdt_client_in_arr "sonarr" "8989"
    fi
}

# Configure NZBGet in *arr service
configure_nzbget_in_arr() {
    local service=$1
    local port=$2
    local api_key=$(get_arr_api_key "$service" "$port")
    
    if [ -n "$api_key" ]; then
        print_info "Adding NZBGet to $service..."
        
        local download_client_data='{
            "enable": true,
            "protocol": "usenet",
            "priority": 1,
            "removeCompletedDownloads": true,
            "removeFailedDownloads": true,
            "name": "NZBGet",
            "fields": [
                {"name": "host", "value": "surge-nzbget"},
                {"name": "port", "value": 6789},
                {"name": "username", "value": "'$NZBGET_USER'"},
                {"name": "password", "value": "'$NZBGET_PASS'"},
                {"name": "category", "value": "'$([ "$service" = "radarr" ] && echo "movies" || echo "tv")'"},
                {"name": "useSsl", "value": false}
            ],
            "implementationName": "NZBGet",
            "implementation": "Nzbget",
            "configContract": "NzbgetSettings",
            "tags": []
        }'
        
        curl -s -X POST "http://localhost:$port/api/v3/downloadclient" \
            -H "Content-Type: application/json" \
            -H "X-Api-Key: $api_key" \
            -d "$download_client_data" > /dev/null
    fi
}

# Configure RDT-Client in *arr service
configure_rdt_client_in_arr() {
    local service=$1
    local port=$2
    local api_key=$(get_arr_api_key "$service" "$port")
    
    if [ -n "$api_key" ]; then
        print_info "Adding RDT-Client to $service..."
        
        local download_client_data='{
            "enable": true,
            "protocol": "torrent",
            "priority": 1,
            "removeCompletedDownloads": true,
            "removeFailedDownloads": true,
            "name": "RDT-Client",
            "fields": [
                {"name": "host", "value": "surge-rdt-client"},
                {"name": "port", "value": 6500},
                {"name": "category", "value": "'$([ "$service" = "radarr" ] && echo "movies" || echo "tv")'"},
                {"name": "useSsl", "value": false}
            ],
            "implementationName": "rTorrent",
            "implementation": "RTorrent",
            "configContract": "RTorrentSettings",
            "tags": []
        }'
        
        curl -s -X POST "http://localhost:$port/api/v3/downloadclient" \
            -H "Content-Type: application/json" \
            -H "X-Api-Key: $api_key" \
            -d "$download_client_data" > /dev/null
    fi
}

# Configure media server connections for various services
configure_media_server_connections() {
    print_info "Configuring media server connections..."
    
    # Configure Overseerr connection to media server
    if [ "$ENABLE_OVERSEERR" = "true" ]; then
        configure_overseerr_media_server
    fi
    
    # Configure Tautulli connection
    if [ "$ENABLE_TAUTULLI" = "true" ]; then
        configure_tautulli_media_server
    fi
}

# Configure Overseerr media server connection
configure_overseerr_media_server() {
    print_info "Configuring Overseerr connection to $MEDIA_SERVER..."
    
    wait_for_service "overseerr" "5055"
    
    case $MEDIA_SERVER in
        plex)
            # Overseerr will need manual Plex token configuration
            print_warning "Overseerr requires manual Plex token configuration"
            print_info "Visit http://localhost:5055/setup to complete Plex integration"
            ;;
        jellyfin)
            print_info "Jellyfin integration will be available in Overseerr setup"
            ;;
        emby)
            print_info "Emby integration will be available in Overseerr setup"
            ;;
    esac
}

# Configure Tautulli media server connection
configure_tautulli_media_server() {
    print_info "Configuring Tautulli connection to $MEDIA_SERVER..."
    
    wait_for_service "tautulli" "8181"
    
    print_info "Tautulli setup: http://localhost:8181/setup"
    case $MEDIA_SERVER in
        plex)
            print_info "Use Plex server: http://surge-plex:32400"
            ;;
        jellyfin)
            print_info "Use Jellyfin server: http://surge-jellyfin:8096"
            ;;
        emby)
            print_info "Use Emby server: http://surge-emby:8096"
            ;;
    esac
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
CONFIG_DIR=\${DATA_ROOT}/config

# DOWNLOAD CLIENT PATHS (Accessible by all containers)
NZBGET_DOWNLOADS=\${DOWNLOADS_DIR}/nzbget
RDT_DOWNLOADS=\${DOWNLOADS_DIR}/rdt-client
COMPLETE_DOWNLOADS=\${DOWNLOADS_DIR}/completed
INCOMPLETE_DOWNLOADS=\${DOWNLOADS_DIR}/incomplete

# MEDIA SERVER SELECTION
MEDIA_SERVER=$MEDIA_SERVER

# SERVICE CONFIGURATION
ENABLE_BAZARR=${ENABLE_BAZARR:-true}
ENABLE_PROWLARR=${ENABLE_PROWLARR:-true}
ENABLE_NZBGET=${ENABLE_NZBGET:-true}
ENABLE_RDT_CLIENT=${ENABLE_RDT_CLIENT:-false}
ENABLE_ZILEAN=${ENABLE_ZILEAN:-true}
ENABLE_CLI_DEBRID=${ENABLE_CLI_DEBRID:-false}
ENABLE_DECYPHARR=${ENABLE_DECYPHARR:-false}
ENABLE_KOMETA=${ENABLE_KOMETA:-true}
ENABLE_POSTERIZARR=${ENABLE_POSTERIZARR:-true}
ENABLE_OVERSEERR=${ENABLE_OVERSEERR:-true}
ENABLE_TAUTULLI=${ENABLE_TAUTULLI:-true}
ENABLE_SCANLY=${ENABLE_SCANLY:-true}
ENABLE_CINESYNC=${ENABLE_CINESYNC:-false}
ENABLE_PLACEHOLDARR=${ENABLE_PLACEHOLDARR:-false}
ENABLE_GAPS=${ENABLE_GAPS:-true}
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
DECYPHARR_PORT=8282
TAUTULLI_PORT=8181
OVERSEERR_PORT=5055
SCANLY_PORT=8183
RDT_CLIENT_PORT=6500
KOMETA_PORT=5556
PLEX_PORT=${PLEX_PORT:-32400}
EMBY_PORT=${EMBY_PORT:-8096}
JELLYFIN_PORT=${JELLYFIN_PORT:-8096}
GAPS_PORT=${GAPS_PORT:-8484}

# AUTOMATION
WATCHTOWER_INTERVAL=${WATCHTOWER_INTERVAL:-86400}
ASSET_PROCESSING_SCHEDULE=${ASSET_PROCESSING_SCHEDULE:-"0 2 * * *"}

# EXTERNAL SERVICES (OPTIONAL)
TMDB_API_KEY=${TMDB_API_KEY:-}
TRAKT_CLIENT_ID=${TRAKT_CLIENT_ID:-}
TRAKT_CLIENT_SECRET=${TRAKT_CLIENT_SECRET:-}
FANART_API_KEY=${FANART_API_KEY:-}
TVDB_API_KEY=${TVDB_API_KEY:-}

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
AD_API_TOKEN=${AD_API_TOKEN:-}
PREMIUMIZE_API_TOKEN=${PREMIUMIZE_API_TOKEN:-}
RD_USERNAME=${RD_USERNAME:-}

# DEPLOYMENT TYPE
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-full}
INSTALL_TYPE=${INSTALL_TYPE:-auto}

# GENERATED TIMESTAMP
CONFIG_GENERATED=$(date '+%Y-%m-%d %H:%M:%S')
CONFIG_VERSION=1.0
EOF

    print_success "Configuration file created"
    
    # Create download directories
    create_download_directories
    
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
    print_info "Configuration saved to .env file"
    print_info "Service configurations created in config directories"
    echo ""
    
    print_info "Would you like to deploy Surge now? (y/n)"
    read -r deploy_now
    
    if [ "$deploy_now" = "y" ] || [ "$deploy_now" = "Y" ]; then
        deploy_stack "$MEDIA_SERVER"
    else
        echo ""
        print_info "To deploy later, run:"
        echo "   cd '$PROJECT_DIR'"
        echo "   bash scripts/deploy.sh $MEDIA_SERVER"
        echo ""
        print_info "After deployment, you can access your services:"
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
        echo "   - Prowlarr: http://localhost:9696"
        
        if [ "$ENABLE_BAZARR" = "true" ]; then
            echo "   - Bazarr: http://localhost:6767"
        fi
        
        if [ "$ENABLE_NZBGET" = "true" ]; then
            echo "   - NZBGet: http://localhost:6789"
        fi
        
        if [ "$ENABLE_RDT_CLIENT" = "true" ]; then
            echo "   - RDT-Client: http://localhost:6500"
        fi
        
        if [ "$ENABLE_CLI_DEBRID" = "true" ]; then
            echo "   - cli_debrid: Available via CLI"
        fi
        
        if [ "$ENABLE_DECYPHARR" = "true" ]; then
            echo "   - Decypharr: http://localhost:8282"
        fi
        
        echo ""
        print_warning "Important: All service interconnections will be configured automatically during deployment!"
    fi
}

# Deploy the stack and configure services
deploy_stack() {
    local media_server=$1
    
    print_step "🚀 Deploying Surge stack with $media_server..."
    
    cd "$PROJECT_DIR"
    
    # Run the deployment script
    if [ -f "$SCRIPT_DIR/deploy.sh" ]; then
        bash "$SCRIPT_DIR/deploy.sh" "$media_server"
        
        if [ $? -eq 0 ]; then
            print_success "Surge stack deployed successfully!"
            
            # Run comprehensive post-deployment configuration
            configure_services_post_deployment
            
            display_final_access_info "$media_server"
        else
            print_error "Failed to deploy Surge stack"
            exit 1
        fi
    else
        print_error "Deploy script not found: $SCRIPT_DIR/deploy.sh"
        exit 1
    fi
}

# Display final access information
display_final_access_info() {
    local media_server=$1
    
    echo ""
    print_step "🌐 Access Information"
    echo ""
    print_success "Surge is now running! Access your services:"
    echo ""
    echo "  📊 Homepage Dashboard: http://localhost:3000"
    echo "  🖼️  Surge Logo: http://localhost:3000/assets/Surge.png"
    echo ""
    
    # Media Server
    case $media_server in
        plex)
            echo "  🎬 Plex Media Server: http://localhost:32400/web"
            ;;
        emby)
            echo "  🎬 Emby Server: http://localhost:8096"
            ;;
        jellyfin)
            echo "  🎬 Jellyfin Server: http://localhost:8096"
            ;;
    esac
    
    # Core services
    echo "  🔍 Prowlarr (Indexer Manager): http://localhost:9696"
    echo "  🎥 Radarr (Movies): http://localhost:7878"
    echo "  📺 Sonarr (TV Shows): http://localhost:8989"

    # GAPS
    if [ "$ENABLE_GAPS" = "true" ]; then
        echo "  🧩 GAPS (Plex Missing Movies): http://localhost:${GAPS_PORT:-8484}"
    fi
    
    # Download clients
    if [ "$ENABLE_NZBGET" = "true" ]; then
        echo "  📥 NZBGet (Usenet): http://localhost:6789"
    fi
    
    if [ "$ENABLE_RDT_CLIENT" = "true" ]; then
        echo "  🌐 RDT-Client (Real-Debrid): http://localhost:6500"
    fi
    
    if [ "$ENABLE_CLI_DEBRID" = "true" ]; then
        echo "  🔧 cli_debrid: Available via CLI"
    fi
    
    if [ "$ENABLE_DECYPHARR" = "true" ]; then
        echo "  🔓 Decypharr (Decryption): http://localhost:8080"
    fi
    
    # Optional services
    if [ "$ENABLE_BAZARR" = "true" ]; then
        echo "  💬 Bazarr (Subtitles): http://localhost:6767"
    fi
    
    if [ "$ENABLE_OVERSEERR" = "true" ]; then
        echo "  🎫 Overseerr (Requests): http://localhost:5055"
    fi
    
    if [ "$ENABLE_TAUTULLI" = "true" ]; then
        echo "  📈 Tautulli (Analytics): http://localhost:8181"
    fi
    
    if [ "$ENABLE_POSTERIZARR" = "true" ]; then
        echo "  🖼️  Posterizarr (Posters): http://localhost:9876"
    fi
    
    echo ""
    print_info "🔧 Automatic Configuration Completed:"
    if [ -n "$RD_API_TOKEN" ]; then
        echo "  ✅ Torrentio indexer auto-configured with your Real-Debrid token"
    fi
    
    if [ "$ENABLE_ZILEAN" = "true" ]; then
        echo "  ✅ Zilean indexer auto-configured in Prowlarr"
    fi
    
    echo "  ✅ Prowlarr connected to Radarr and Sonarr"
    echo "  ✅ Download clients configured in Radarr and Sonarr"
    echo "  ✅ Download paths configured for container accessibility"
    echo ""
    
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        echo "  📱 Discord notifications configured"
    fi
    
    echo ""
    print_success "🎊 Setup complete! Enjoy your fully automated media management stack!"
    echo ""
    print_info "💡 Pro Tips:"
    echo "  - Check the Homepage dashboard for service status"
    echo "  - Prowlarr will automatically sync indexers to Radarr/Sonarr"
    echo "  - Download clients are pre-configured and ready to use"
    echo "  - Monitor everything through Tautulli if enabled"
    echo ""
}

# Mark as initialized
mark_initialized() {
    echo "$(date): Surge initialized with $MEDIA_SERVER" > "$PROJECT_DIR/.surge_initialized"
}

# Detect new variables in updated containers
detect_new_variables() {
    print_step "🔍 Checking for configuration updates..."
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        echo ""
        print_success "Welcome to Surge! Let's get your unified media stack set up."
        return 0
    fi
    # Get current config version
    current_version=$(grep "CONFIG_VERSION=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2)
    expected_version="1.0"
    if [ -z "$current_version" ]; then
        echo ""
        print_success "Welcome to Surge! Let's get your unified media stack set up."
        return 0
    fi
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

        # Source .env to load STORAGE_PATH, PUID, PGID, etc.
        source "$PROJECT_DIR/.env"
        export STORAGE_PATH PUID PGID

        # Create directories (now STORAGE_PATH is set)
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
        return
    fi

    # For existing config, keep legacy flow
    # Source .env and export needed variables before creating directories
    if [ -f "$PROJECT_DIR/.env" ]; then
        source "$PROJECT_DIR/.env"
        export STORAGE_PATH PUID PGID
        # Validate required variables before creating directories
        missing_vars=false
        if [ -z "$STORAGE_PATH" ]; then
            print_warning "STORAGE_PATH is missing from your configuration."
            echo "This is the main folder where Surge will store all media, downloads, and configs."
            echo "Recommended default: /opt/surge"
            read -p "Enter storage path [/opt/surge]: " storage_path
            STORAGE_PATH=${storage_path:-/opt/surge}
            missing_vars=true
        fi
        if [ -z "$PUID" ]; then
            print_warning "PUID (user ID) is missing from your configuration."
            echo "This should be the user ID that will own the files."
            echo "Recommended: your current user ID ($(id -u))"
            read -p "Enter user ID [$(id -u)]: " puid
            PUID=${puid:-$(id -u)}
            missing_vars=true
        fi
        if [ -z "$PGID" ]; then
            print_warning "PGID (group ID) is missing from your configuration."
            echo "This should be the group ID that will own the files."
            echo "Recommended: your current group ID ($(id -g))"
            read -p "Enter group ID [$(id -g)]: " pgid
            PGID=${pgid:-$(id -g)}
            missing_vars=true
        fi
        if [ "$missing_vars" = true ]; then
            print_info "Updating .env with missing values..."
            # Update .env file with new values
            sed -i "/^STORAGE_PATH=/d" "$PROJECT_DIR/.env"
            sed -i "/^PUID=/d" "$PROJECT_DIR/.env"
            sed -i "/^PGID=/d" "$PROJECT_DIR/.env"
            echo "STORAGE_PATH=$STORAGE_PATH" >> "$PROJECT_DIR/.env"
            echo "PUID=$PUID" >> "$PROJECT_DIR/.env"
            echo "PGID=$PGID" >> "$PROJECT_DIR/.env"
            # Re-source .env to ensure variables are loaded
            source "$PROJECT_DIR/.env"
            export STORAGE_PATH PUID PGID
            print_info "Debug: Loaded values after update:"
            echo "  STORAGE_PATH=$STORAGE_PATH"
            echo "  PUID=$PUID"
            echo "  PGID=$PGID"
            print_success "Configuration updated. Continuing setup..."
        fi
    fi
    create_directories
    create_service_configs
    mark_initialized
    show_next_steps
    if [ -n "$DISCORD_WEBHOOK_URL" ] && [ -f "$PROJECT_DIR/scripts/shared-config.sh" ]; then
        print_step "Sending setup completion notification..."
        source "$PROJECT_DIR/.env"
        "$PROJECT_DIR/scripts/shared-config.sh" test-webhook
    fi
}

# Run main function
main "$@"
