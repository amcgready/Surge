
# Utility function definitions (must be before any usage)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
DARK_BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Main setup logic for both initial setup and --reconfigure
main_setup_logic() {
    # Admin credentials setup for integrated services
    print_step "Setting default admin credentials for all *arr services (admin / your chosen password)"
    DEFAULT_ARR_USER="admin"
    DEFAULT_ARR_HASH="HnxsPdd7O+41SaNwktBU4ax7QuR41BA3ibq/UITYg5o="
    DEFAULT_ARR_SALT="IKT1ieqFHoJ/hTfSp+Um7Q=="
    DEFAULT_ARR_ITER=10000
    print_success "Default admin credentials set for Prowlarr, Sonarr, and Radarr."

    # Patch Users table for all *arr services after deployment
    patch_arr_users() {
        local db_path="$1"
        if [ -f "$db_path" ]; then
            sqlite3 "$db_path" "UPDATE Users SET username='${DEFAULT_ARR_USER}', password_hash='${DEFAULT_ARR_HASH}', password_salt='${DEFAULT_ARR_SALT}', iterations=${DEFAULT_ARR_ITER} WHERE id=1;"
            echo "Patched Users table in $db_path"
        else
            echo "Database not found: $db_path"
        fi
    }

    # After deployment, patch all *arr DBs
    ARR_DB_PATHS=(
        "$STORAGE_PATH/Prowlarr/config/prowlarr.db"
        "$STORAGE_PATH/Sonarr/config/sonarr.db"
        "$STORAGE_PATH/Radarr/config/radarr.db"
    )
    for db in "${ARR_DB_PATHS[@]}"; do
        patch_arr_users "$db"
    done

    # ...existing code for install type, media server, deployment type, etc...

    # After deployment type and service selection, but BEFORE Plex setup, prompt for CineSync folders if enabled
    # (Assume DEPLOYMENT_TYPE and ENABLE_CINESYNC are set by gather_auto_preferences/gather_custom_preferences)
    if [ "$ENABLE_CINESYNC" = "true" ]; then
        configure_cinesync_organization
    fi

    # Now proceed to Plex setup, using CineSync folder variables for library creation
}

# Call main setup logic at the start of the script
main_setup_logic

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

# Source API key utilities
source "$SCRIPT_DIR/api-key-utils.sh"

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

# Progress bar function with time estimate
show_progress_bar() {
    local message="$1"
    local duration="${2:-30}"  # Default 30 seconds
    local steps=50
    
    # Calculate delay using shell arithmetic (fallback if bc not available)
    if command -v bc >/dev/null 2>&1; then
        local delay=$(echo "scale=2; $duration / $steps" | bc -l)
    else
        local delay=$((duration * 100 / steps))  # Use centiseconds
        delay="0.$(printf "%02d" $delay)"
    fi
    
    echo -e "${CYAN}[PROGRESS]${NC} $message"
    echo -ne "["
    
    for ((i=0; i<=steps; i++)); do
        # Calculate percentage
        local percent=$((i * 100 / steps))
        
        # Show progress bar
        if [ $i -lt $steps ]; then
            echo -ne "="
        else
            echo -ne "="
        fi
        
        # Show percentage and time remaining
        local remaining=$((duration - (i * duration / steps)))
        if [ $i -eq $steps ]; then
            echo -e "] ${GREEN}100%${NC} - Complete!"
        else
            echo -ne "\r["
            for ((j=0; j<i; j++)); do echo -ne "="; done
            for ((j=i; j<steps; j++)); do echo -ne " "; done
            echo -ne "] ${YELLOW}$percent%${NC} - ETA: ${remaining}s"
        fi
        
        # Don't sleep on last iteration
        if [ $i -lt $steps ]; then
            if command -v bc >/dev/null 2>&1; then
                sleep "$delay"
            else
                # Fallback: use basic sleep with integer seconds
                sleep 1
            fi
        fi
    done
    echo
}

# Quick progress bar for shorter operations
show_quick_progress() {
    local message="$1"
    local duration="${2:-10}"  # Default 10 seconds
    
    echo -e "${CYAN}[PROGRESS]${NC} $message"
    echo -ne "Working: "
    
    local spinner_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local spinner_length=${#spinner_chars}
    
    for ((i=0; i<duration; i++)); do
        local char_index=$((i % spinner_length))
        echo -ne "${spinner_chars:$char_index:1}"
        echo -ne "\b"
        sleep 1
    done
    echo -e "${GREEN}✓${NC} Complete!"
}

# Check if this is first run
check_first_run() {
    # Check all arguments for --reconfigure flag
    for arg in "$@"; do
        if [ "$arg" = "--reconfigure" ]; then
            print_info "🔄 Reconfiguring existing Surge installation..."
            return 0
        fi
    done
    
    if [ -f "$PROJECT_DIR/.surge_initialized" ]; then
        print_info "Surge has already been initialized"
        echo "Run './surge deploy <media-server>' to start services"
        echo "Run './surge setup --reconfigure' to reconfigure"
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
    PLEX_CONFIG_DIR="${STORAGE_PATH}/config/plex"
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
    echo "Press Enter to accept defaults for any prompt."
    echo "We'll only ask for the essentials and API keys!"
    echo ""

    print_step "Setting default admin credentials for all *arr services (admin / your chosen password)"
    # ...existing code...
    
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
    # Plex server name configuration (required for proper library setup)
    if [ "$MEDIA_SERVER" = "plex" ]; then
        echo ""
        print_info "Plex Server Configuration"
        echo "Enter a name for your Plex server (required for proper library setup)"
        echo "This will be displayed in the Plex interface and used for identification"
        read -p "Plex server name [MyPlexServer]: " plex_server_name
        PLEX_SERVER_NAME=${plex_server_name:-MyPlexServer}
        print_success "Plex server name set to: $PLEX_SERVER_NAME"
        echo ""
        print_info "Opening web browser for Plex claim token..."
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "https://plex.tv/claim" >/dev/null 2>&1 &
        else
            echo "Please open https://plex.tv/claim in your browser to get your Plex claim token."
        fi
        echo "Generate your Plex claim token here: ${YELLOW}https://plex.tv/claim${NC} (login required)"
        while true; do
            read -p "Paste your Plex claim token: " plex_claim_token
            if [ -n "$plex_claim_token" ]; then
                break
            else
                print_error "Plex claim token is required to continue. Please paste your token."
            fi
        done
        PLEX_CLAIM=${plex_claim_token}
    fi
    
    # Storage location (simplified)
    echo ""
    print_info "Storage Configuration"
    echo "Where should Surge store your media and configurations?"
    echo "Press Enter for default: /opt/surge (recommended for most users)"
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
    echo "If left blank, Discord notifications will be OFF."
    echo "If a webhook URL is provided, ALL notification types will be ON."
    read -p "Discord webhook URL (optional): " discord_webhook
    DISCORD_WEBHOOK_URL=${discord_webhook:-}
    NOTIFICATION_TITLE_PREFIX="Surge"
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        DISCORD_NOTIFY_UPDATES="true"
        DISCORD_NOTIFY_PROCESSING="true"
        DISCORD_NOTIFY_ERRORS="true"
        DISCORD_NOTIFY_MEDIA="true"
        DISCORD_NOTIFY_SYSTEM="true"
    else
        print_info "No Discord webhook provided. All Discord notifications are OFF."
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
    ENABLE_CLI_DEBRID="true"
    ENABLE_DECYPHARR="true"
    ENABLE_CINESYNC="true"
    ENABLE_PLACEHOLDARR="true"
    ENABLE_GAPS="true"
    ENABLE_WATCHTOWER="true"
    ENABLE_SCHEDULER="true"
    ENABLE_RDT_CLIENT="true"
    ENABLE_PD_ZURG="false"
    DEPLOYMENT_TYPE="full"

    # Prompt for CineSync folder options if enabled (always in auto mode)
    if [ "$ENABLE_CINESYNC" = "true" ]; then
        configure_cinesync_organization
    fi

    # Set Zurg downloads path and CineSync origin path
    PD_ZURG_DOWNLOADS_PATH="$STORAGE_PATH/downloads/pd_zurg"
    if [ "$ENABLE_PD_ZURG" = "true" ]; then
        CINESYNC_ORIGIN_PATH="$STORAGE_PATH/downloads/pd_zurg/__all__"
    else
        CINESYNC_ORIGIN_PATH="$STORAGE_PATH/downloads/Zurg"
    fi

    # API Keys and External Services (wording and logic unified with custom install)
    echo ""
    print_info "External Services & Notifications"

    # Debrid Services Section
    echo ""
    print_info "Debrid Services (Real-Debrid, AllDebrid, Premiumize)"
    echo "Provide at least one debrid API token to enable Torrentio, Zurg, and cli-debrid."
    echo "If none are provided, these features will be disabled."
    echo ""
    read -p "Real-Debrid API Token (recommended): " RD_API_TOKEN
    read -p "AllDebrid API Token (optional): " AD_API_TOKEN
    read -p "Premiumize API Token (optional): " PREMIUMIZE_API_TOKEN

    # Determine which token to use for all debrid features
    if [ -n "$RD_API_TOKEN" ]; then
        DEBRID_PROVIDER="realdebrid"
        DEBRID_TOKEN="$RD_API_TOKEN"
    elif [ -n "$AD_API_TOKEN" ]; then
        DEBRID_PROVIDER="alldebrid"
        DEBRID_TOKEN="$AD_API_TOKEN"
    elif [ -n "$PREMIUMIZE_API_TOKEN" ]; then
        DEBRID_PROVIDER="premiumize"
        DEBRID_TOKEN="$PREMIUMIZE_API_TOKEN"
    else
        DEBRID_PROVIDER="none"
        DEBRID_TOKEN=""
    fi

    # Apply token to all relevant services, or disable if none provided
    if [ "$DEBRID_PROVIDER" = "none" ]; then
        print_warning "No debrid token provided. Torrentio, Zurg, and cli-debrid will be disabled."
        ENABLE_TORRENTIO="false"
        ENABLE_ZURG="false"
        ENABLE_CLI_DEBRID="false"
        ENABLE_RDT_CLIENT="false"
    else
        print_success "Using $DEBRID_PROVIDER token for all debrid features."
        ENABLE_TORRENTIO="true"
        ENABLE_ZURG="true"
        ENABLE_CLI_DEBRID="true"
        ENABLE_RDT_CLIENT="true"
    fi

    export RD_API_TOKEN
    export AD_API_TOKEN
    export PREMIUMIZE_API_TOKEN
    export ENABLE_TORRENTIO
    export ENABLE_ZURG
    export ENABLE_CLI_DEBRID
    export ENABLE_RDT_CLIENT

    # TMDB and Trakt
    echo "\nTMDB API Key (for metadata, optional)"
    echo "  Get your TMDB API key here: https://www.themoviedb.org/settings/api (login required)"
    read -p "TMDB API Key: " tmdb_key
    TMDB_API_KEY=${tmdb_key:-}

    echo "\nTrakt Client ID (optional)"
    echo "  Get your Trakt API credentials here: https://trakt.tv/oauth/applications (login required)"
    read -p "Trakt Client ID: " trakt_id
    TRAKT_CLIENT_ID=${trakt_id:-}
    if [ -n "$TRAKT_CLIENT_ID" ]; then
        read -p "Trakt Client Secret: " trakt_secret
        TRAKT_CLIENT_SECRET=${trakt_secret:-}
    fi

    if [ "$ENABLE_NZBGET" = "true" ]; then
        echo ""
        print_info "NZBGet Configuration"
        export NZBGET_USER="admin"
        export NZBGET_PASS="password"
        export OVERSEERR_USER="admin"
        export OVERSEERR_PASS="password"
        export TAUTULLI_USER="admin"
        export TAUTULLI_PASS="password"
        print_info "Using admin credentials for NZBGet."
    fi

    if [ "$ENABLE_POSTERIZARR" = "true" ]; then
        echo ""
        echo "🎨 Posterizarr Enhanced Configuration:"
        echo "Fanart.tv API Key (optional)"
        echo "  Get your Fanart.tv API key here: https://fanart.tv/users/apikey (login required)"
        read -p "Fanart.tv API Key: " fanart_key
        FANART_API_KEY=${fanart_key:-}

        echo "TVDB API Key (optional)"
        echo "  Get your TVDB API key here: https://thetvdb.com/api-information (login required)"
        read -p "TVDB API Key: " tvdb_key
        TVDB_API_KEY=${tvdb_key:-}
    fi

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
    
    # Plex server name configuration (required for proper library setup)
    if [ "$MEDIA_SERVER" = "plex" ]; then
        echo ""
        print_info "Plex Server Configuration"
        echo "Enter a name for your Plex server (required for proper library setup)"
        echo "This will be displayed in the Plex interface and used for identification"
        read -p "Plex server name [MyPlexServer]: " plex_server_name
        PLEX_SERVER_NAME=${plex_server_name:-MyPlexServer}
        print_success "Plex server name set to: $PLEX_SERVER_NAME"
        echo ""
    fi
    
    # Deployment type
    echo ""
    echo "Choose deployment type:"
    echo "1) Full Stack - All services and features"
    echo "2) Minimal - Core services only (media server + automation)"
    echo "3) Custom - Choose specific services"
    read -p "Enter choice (1-3): " deploy_choice

    case $deploy_choice in
        1)
            DEPLOYMENT_TYPE="full"
            ENABLE_CINESYNC="true"
            ENABLE_PD_ZURG="false"
            export ENABLE_PD_ZURG
            ;;
        2)
            DEPLOYMENT_TYPE="minimal"
            ENABLE_CINESYNC="false"
            ;;
        3)
            DEPLOYMENT_TYPE="custom"
            # Will prompt for CineSync below
            ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac

    # Prompt for CineSync folder options immediately after deployment type selection
    if [ "$DEPLOYMENT_TYPE" = "full" ]; then
        if [ "$ENABLE_CINESYNC" = "true" ]; then
            configure_cinesync_organization
        fi
    elif [ "$DEPLOYMENT_TYPE" = "custom" ]; then
        read -p "Enable CineSync (media organization)? [Y/n]: " enable_cinesync
        ENABLE_CINESYNC=$([[ "$enable_cinesync" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        if [ "$ENABLE_CINESYNC" = "true" ]; then
            configure_cinesync_organization
        fi
    fi
    # Set Zurg downloads path and CineSync origin path (always, no prompt)
    PD_ZURG_DOWNLOADS_PATH="$STORAGE_PATH/downloads/pd_zurg"
    if [ "$ENABLE_PD_ZURG" = "true" ]; then
        CINESYNC_ORIGIN_PATH="$STORAGE_PATH/downloads/pd_zurg/__all__"
    else
        CINESYNC_ORIGIN_PATH="$STORAGE_PATH/downloads/Zurg"
    fi

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
        read -p "Enable Zurg (Real-Debrid filesystem)? [y/N]: " enable_zurg
        ENABLE_ZURG=$([[ "$enable_zurg" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        read -p "Enable cli_debrid (debrid CLI management)? [y/N]: " enable_cli_debrid
        ENABLE_CLI_DEBRID=$([[ "$enable_cli_debrid" =~ ^[Yy]$ ]] && echo "true" || echo "false")
        # =============================
        # Debrid Service Configuration
        # =============================
        if [ "$ENABLE_RDT_CLIENT" = "true" ] || [ "$ENABLE_ZURG" = "true" ] || [ "$ENABLE_CLI_DEBRID" = "true" ]; then
            echo ""
            print_info "Debrid Service Configuration"
            echo "Provide at least one debrid API token to enable Torrentio, Zurg, and cli-debrid."
            echo "If none are provided, these features will be disabled."
            echo ""
            read -p "Real-Debrid API Token (recommended): " RD_API_TOKEN
            read -p "AllDebrid API Token (optional): " AD_API_TOKEN
            read -p "Premiumize API Token (optional): " PREMIUMIZE_API_TOKEN

            # Determine which token to use for all debrid features
            if [ -n "$RD_API_TOKEN" ]; then
                DEBRID_PROVIDER="realdebrid"
                DEBRID_TOKEN="$RD_API_TOKEN"
            elif [ -n "$AD_API_TOKEN" ]; then
                DEBRID_PROVIDER="alldebrid"
                DEBRID_TOKEN="$AD_API_TOKEN"
            elif [ -n "$PREMIUMIZE_API_TOKEN" ]; then
                DEBRID_PROVIDER="premiumize"
                DEBRID_TOKEN="$PREMIUMIZE_API_TOKEN"
            else
                DEBRID_PROVIDER="none"
                DEBRID_TOKEN=""
            fi

            # Apply token to all relevant services, or disable if none provided
            if [ "$DEBRID_PROVIDER" = "none" ]; then
                print_warning "No debrid token provided. Torrentio, Zurg, and cli-debrid will be disabled."
                ENABLE_TORRENTIO="false"
                ENABLE_ZURG="false"
                ENABLE_CLI_DEBRID="false"
                ENABLE_RDT_CLIENT="false"
            else
                print_success "Using $DEBRID_PROVIDER token for all debrid features."
                ENABLE_TORRENTIO="true"
                ENABLE_ZURG="true"
                ENABLE_CLI_DEBRID="true"
                ENABLE_RDT_CLIENT="true"
            fi

            # Export for downstream scripts
            export RD_API_TOKEN
            export AD_API_TOKEN
            export PREMIUMIZE_API_TOKEN
            export ENABLE_TORRENTIO
            export ENABLE_ZURG
            export ENABLE_CLI_DEBRID
            export ENABLE_RDT_CLIENT
        fi
        # Prompt for custom Zurg downloads path if Zurg is enabled
        if [ "$ENABLE_ZURG" = "true" ]; then
            echo ""
            print_info "Zurg downloads destination"
            echo "Default: Uses standard Surge downloads directory"
            read -p "Custom Zurg downloads path (optional): " PD_ZURG_DOWNLOADS_PATH
            PD_ZURG_DOWNLOADS_PATH=${PD_ZURG_DOWNLOADS_PATH:-}
        fi
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
        read -p "Enable CineSync (media organization)? [Y/n]: " enable_cinesync
        ENABLE_CINESYNC=$([[ "$enable_cinesync" =~ ^[Nn]$ ]] && echo "false" || echo "true")
        read -p "Enable Placeholdarr? [y/N]: " enable_placeholdarr
        ENABLE_PLACEHOLDARR=$([[ "$enable_placeholdarr" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    elif [ "$DEPLOYMENT_TYPE" = "minimal" ]; then
        # Minimal deployment
        ENABLE_BAZARR="false"
        ENABLE_PROWLARR="true"
        ENABLE_NZBGET="true"
        ENABLE_RDT_CLIENT="false"
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
        ENABLE_CLI_DEBRID="false"
        ENABLE_DECYPHARR="false"
        ENABLE_KOMETA="true"
        ENABLE_POSTERIZARR="true"
        ENABLE_OVERSEERR="true"
        ENABLE_TAUTULLI="true"
        ENABLE_SCANLY="true"
        ENABLE_CINESYNC="true"
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
    
    # API Keys and External Services (wording unified with auto install)
    echo ""
    print_info "External Services & Notifications"
    echo ""
    print_info "🔔 Discord Notifications (Optional)"
    echo "If left blank, Discord notifications will be OFF."
    echo "If a webhook URL is provided, ALL notification types will be ON."
    read -p "Discord webhook URL (optional): " discord_webhook
    DISCORD_WEBHOOK_URL=${discord_webhook:-}
    NOTIFICATION_TITLE_PREFIX="Surge"
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        DISCORD_NOTIFY_UPDATES="true"
        DISCORD_NOTIFY_PROCESSING="true"
        DISCORD_NOTIFY_ERRORS="true"
        DISCORD_NOTIFY_MEDIA="true"
        DISCORD_NOTIFY_SYSTEM="true"
    else
        print_info "No Discord webhook provided. All Discord notifications are OFF."
        DISCORD_NOTIFY_UPDATES="false"
        DISCORD_NOTIFY_PROCESSING="false"
        DISCORD_NOTIFY_ERRORS="false"
        DISCORD_NOTIFY_MEDIA="false"
        DISCORD_NOTIFY_SYSTEM="false"
    fi

    echo "\nTMDB API Key (for metadata, optional)"
    echo "  Get your TMDB API key here: https://www.themoviedb.org/settings/api (login required)"
    read -p "TMDB API Key: " tmdb_key
    TMDB_API_KEY=${tmdb_key:-}

    echo "\nTrakt Client ID (optional)"
    echo "  Get your Trakt API credentials here: https://trakt.tv/oauth/applications (login required)"
    read -p "Trakt Client ID: " trakt_id
    TRAKT_CLIENT_ID=${trakt_id:-}
    if [ -n "$TRAKT_CLIENT_ID" ]; then
        read -p "Trakt Client Secret: " trakt_secret
        TRAKT_CLIENT_SECRET=${trakt_secret:-}
    fi

    if [ "$ENABLE_NZBGET" = "true" ]; then
        echo ""
        print_info "NZBGet Configuration"
        export NZBGET_USER="admin"
        export NZBGET_PASS="password"
        export OVERSEERR_USER="admin"
        export OVERSEERR_PASS="password"
        export TAUTULLI_USER="admin"
        export TAUTULLI_PASS="password"
        print_info "Using admin credentials for NZBGet."
    fi

    if [ "$ENABLE_RDT_CLIENT" = "true" ]; then
        echo ""
        print_info "Real-Debrid Configuration"
        read -p "Real-Debrid API Token: " rd_token
        RD_API_TOKEN=${rd_token:-}
    fi

    echo ""
    print_info "Additional API Keys (Enhanced Integration)"
    echo "These API keys enable full automation and advanced features:"

    if [ "$ENABLE_PROWLARR" = "true" ]; then
        echo ""
        echo "📡 Prowlarr will be auto-configured with:"
        echo "• Torrentio indexer (requires Real-Debrid API key)"
        echo "• Auto-connection to Radarr and Sonarr"
        if [ -z "$RD_API_TOKEN" ]; then
            read -p "Real-Debrid API Token (for Torrentio) (optional): " prowlarr_rd_token
            RD_API_TOKEN=${prowlarr_rd_token:-}
        else
            print_info "✅ Using Real-Debrid token already provided for RDT-Client/Zurg"
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
        echo "Fanart.tv API Key (optional)"
        echo "  Get your Fanart.tv API key here: https://fanart.tv/users/apikey (login required)"
        read -p "Fanart.tv API Key: " fanart_key
        FANART_API_KEY=${fanart_key:-}

        echo "TVDB API Key (optional)"
        echo "  Get your TVDB API key here: https://thetvdb.com/api-information (login required)"
        read -p "TVDB API Key: " tvdb_key
        TVDB_API_KEY=${tvdb_key:-}
    fi
}

# Create download directories with proper permissions
create_download_directories() {
    print_step "Creating download directories..."
    show_quick_progress "Setting up directory structure..." 8
    
    # Create directory structure
    mkdir -p "$STORAGE_PATH/downloads/"{nzbget,rdt-client,completed,incomplete}
    mkdir -p "$STORAGE_PATH/downloads/completed/"{movies,tv}
    mkdir -p "$STORAGE_PATH/downloads/incomplete/"{movies,tv}
    
    # Set proper permissions on the main Surge directory only
    if [ -d "$STORAGE_PATH/Surge" ]; then
        chmod 755 "$STORAGE_PATH/Surge" 2>/dev/null || print_warning "Could not chmod $STORAGE_PATH/Surge (may be a network share)"
        if [ "$EUID" -eq 0 ]; then
            chown -R "$PUID:$PGID" "$STORAGE_PATH/Surge" 2>/dev/null || print_warning "Could not chown $STORAGE_PATH/Surge (may be a network share)"
        fi
    else
        print_warning "$STORAGE_PATH/Surge does not exist, skipping permission changes."
    fi
    print_success "Download directories created and configured"
}

# Interactive CineSync Media Organization Configuration
configure_cinesync_organization() {
    echo ""
    print_info "🎬 CineSync Media Organization Setup"
    echo ""
    echo "Configure how CineSync organizes your media library:"
    echo ""
    
    # Content separation options
    echo "📂 Content Separation Options:"
    echo ""
    
    # Anime separation
    read -p "Separate anime content into dedicated folders? [Y/n]: " anime_separation
    CINESYNC_ANIME_SEPARATION=$([[ "$anime_separation" =~ ^[Nn]$ ]] && echo "false" || echo "true")
    
    if [ "$CINESYNC_ANIME_SEPARATION" = "true" ]; then
        echo "  📺 Anime content will be organized separately"
        read -p "    Anime TV folder name [Anime Series]: " anime_tv_name
        CINESYNC_CUSTOM_ANIME_SHOW_FOLDER=${anime_tv_name:-"Anime Series"}
        
        read -p "    Anime movie folder name [Anime Movies]: " anime_movie_name
        CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER=${anime_movie_name:-"Anime Movies"}
    fi
    
    # 4K separation
    read -p "Separate 4K content into dedicated folders? [y/N]: " fourk_separation
    CINESYNC_4K_SEPARATION=$([[ "$fourk_separation" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    if [ "$CINESYNC_4K_SEPARATION" = "true" ]; then
        echo "  🎞️ 4K content will be organized separately"
        read -p "    4K TV folder name [4K Series]: " fourk_tv_name
        CINESYNC_CUSTOM_4KSHOW_FOLDER=${fourk_tv_name:-"4K Series"}
        
        read -p "    4K movie folder name [4K Movies]: " fourk_movie_name
        CINESYNC_CUSTOM_4KMOVIE_FOLDER=${fourk_movie_name:-"4K Movies"}
    fi
    
    # Kids content separation
    read -p "Separate family/kids content into dedicated folders? [y/N]: " kids_separation
    CINESYNC_KIDS_SEPARATION=$([[ "$kids_separation" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    if [ "$CINESYNC_KIDS_SEPARATION" = "true" ]; then
        echo "  👶 Kids content will be organized separately"
        read -p "    Kids TV folder name [Kids Series]: " kids_tv_name
        CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=${kids_tv_name:-"Kids Series"}
        
        read -p "    Kids movie folder name [Kids Movies]: " kids_movie_name
        CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=${kids_movie_name:-"Kids Movies"}
    fi
    
    echo ""
    echo "📁 Standard Library Folders:"
    
    # Standard folder names
    read -p "TV Shows folder name [TV Series]: " tv_folder_name
    CINESYNC_CUSTOM_SHOW_FOLDER=${tv_folder_name:-"TV Series"}
    
    read -p "Movies folder name [Movies]: " movie_folder_name
    CINESYNC_CUSTOM_MOVIE_FOLDER=${movie_folder_name:-"Movies"}
    
    echo ""
    echo "🔧 Advanced Organization Options:"
    
    # Resolution-based organization
    read -p "Organize by resolution within folders (e.g., Movies/1080p, Movies/720p)? [y/N]: " resolution_structure
    CINESYNC_SHOW_RESOLUTION_STRUCTURE=$([[ "$resolution_structure" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    CINESYNC_MOVIE_RESOLUTION_STRUCTURE=$([[ "$resolution_structure" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    # Source structure preservation
    read -p "Preserve original source folder structure? [y/N]: " source_structure
    CINESYNC_USE_SOURCE_STRUCTURE=$([[ "$source_structure" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    echo ""
    print_info "✅ CineSync Organization Configuration Complete"
    echo ""
    echo "📂 Your media will be organized as follows:"
    echo "   📺 TV Shows: $CINESYNC_CUSTOM_SHOW_FOLDER"
    echo "   🎬 Movies: $CINESYNC_CUSTOM_MOVIE_FOLDER"
    
    if [ "$CINESYNC_ANIME_SEPARATION" = "true" ]; then
        echo "   🗾 Anime TV: $CINESYNC_CUSTOM_ANIME_SHOW_FOLDER"
        echo "   🎌 Anime Movies: $CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER"
    fi
    
    if [ "$CINESYNC_4K_SEPARATION" = "true" ]; then
        echo "   📺 4K TV: $CINESYNC_CUSTOM_4KSHOW_FOLDER"
        echo "   🎞️ 4K Movies: $CINESYNC_CUSTOM_4KMOVIE_FOLDER"
    fi
    
    if [ "$CINESYNC_KIDS_SEPARATION" = "true" ]; then
        echo "   👶 Kids TV: $CINESYNC_CUSTOM_KIDS_SHOW_FOLDER"
        echo "   🧸 Kids Movies: $CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER"
    fi
    
    if [ "$CINESYNC_SHOW_RESOLUTION_STRUCTURE" = "true" ]; then
        echo "   📐 Resolution-based sub-folders: Enabled"
    fi
    
    if [ "$CINESYNC_USE_SOURCE_STRUCTURE" = "true" ]; then
        echo "   📋 Source structure preservation: Enabled"
    fi
    
    echo ""
}

# Comprehensive post-deployment configuration
configure_services_post_deployment() {
    print_step "🔧 Configuring service interconnections..."
    
    # Wait for services to start up
    print_info "Waiting for services to initialize..."
    show_progress_bar "Services are starting up and creating configuration files..." 30
    sleep 30
    
    # Allow additional time for API key generation
    print_info "Allowing extra time for API key generation..."
    show_progress_bar "Services are generating API keys and finalizing setup..." 25
    sleep 25
    
    # Skipping browser prompt and user authentication confirmation; proceeding directly to API key extraction and configuration


    # Always extract API keys from config.xml files (no user prompt), using robust retry logic for Prowlarr
    PROWLARR_API_KEY=$(get_prowlarr_api_key)
    RADARR_CONFIG="$STORAGE_PATH/Radarr/config/config.xml"
    SONARR_CONFIG="$STORAGE_PATH/Sonarr/config/config.xml"
    RADARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' "$RADARR_CONFIG" 2>/dev/null || echo "")
    SONARR_API_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' "$SONARR_CONFIG" 2>/dev/null || echo "")

    if [ -z "$PROWLARR_API_KEY" ] || [ -z "$RADARR_API_KEY" ] || [ -z "$SONARR_API_KEY" ]; then
        print_warning "Could not automatically extract all API keys. Please ensure you have completed initial setup in the web UI for each service."
        print_warning "You must complete the initial setup in the web UI for Prowlarr, Radarr, and Sonarr before running this script."
        exit 1
    fi
    export PROWLARR_API_KEY RADARR_API_KEY SONARR_API_KEY

    # Configure Prowlarr indexers and connections
    if [ "$ENABLE_PROWLARR" = "true" ]; then
        print_info "Connecting Prowlarr to Radarr and Sonarr..."
        show_quick_progress "Setting up Prowlarr indexers and connections..." 20
        connect_prowlarr_to_arr_services
        if [ $? -ne 0 ]; then
            print_error "Failed to add Prowlarr connections or indexers! Please check your authentication and try again."
        fi
    fi

    # Configure NZBGet comprehensive automation
    if [ "$ENABLE_NZBGET" = "true" ]; then
        print_info "🔧 Running NZBGet comprehensive automation..."
        show_quick_progress "Configuring NZBGet automation settings..." 15
        python3 "$SCRIPT_DIR/configure-nzbget.py" "$STORAGE_PATH"
        if [ $? -eq 0 ]; then
            print_success "NZBGet automation completed successfully!"
        else
            print_warning "NZBGet automation had some issues, manual configuration may be needed"
        fi
    fi

    # Configure download clients in Radarr/Sonarr
    configure_arr_download_clients

    # Configure media server connections
    configure_media_server_connections

    # Configure homepage widgets for all enabled services
    configure_homepage_widgets


    # Prompt for sudo password and fix ownership of storage path (removes locks)
    echo "\nTo ensure you have access to all files, your sudo password may be required to fix permissions and remove any locks."
    echo "DEBUG: STORAGE_PATH='$STORAGE_PATH' PUID='$PUID' PGID='$PGID'"
    if [ -z "$STORAGE_PATH" ] || [ -z "$PUID" ] || [ -z "$PGID" ]; then
        print_error "STORAGE_PATH, PUID, or PGID is not set. Cannot set ownership."
        exit 1
    fi
    sudo -v
    sudo chown -R "$PUID:$PGID" "$STORAGE_PATH"
    print_success "All files and folders in $STORAGE_PATH are now owned by $PUID:$PGID. (Locks removed)"

    # Run automatic API discovery and configuration
    print_info "🔧 Running automatic service configuration..."
    show_progress_bar "Running advanced API discovery and service configuration..." 60
    if [ -x "$SCRIPT_DIR/auto-config.sh" ]; then
        "$SCRIPT_DIR/auto-config.sh" --storage-path "$STORAGE_PATH" --wait-timeout 120
        if [ $? -eq 0 ]; then
            print_success "Automatic service configuration completed!"
        else
            print_warning "Automatic configuration had some issues, but services should still work"
        fi
    fi

    # Configure Homepage dashboard
    print_info "🏠 Configuring Homepage dashboard..."
    show_quick_progress "Setting up Homepage dashboard with all enabled services..." 15
    if python3 "$SCRIPT_DIR/configure-homepage.py" "$STORAGE_PATH"; then
        print_success "Homepage dashboard configuration completed!"
        print_info "📊 Homepage dashboard available at: http://localhost:${HOMEPAGE_PORT:-3000}"
    else
        print_warning "Homepage configuration had some issues, but basic dashboard should work"
    fi

    # Configure Posterizarr if enabled
    if [ "$ENABLE_POSTERIZARR" = "true" ]; then
        print_info "🎨 Configuring Posterizarr poster management..."
        show_quick_progress "Setting up automated poster management..." 10
        if python3 "$SCRIPT_DIR/configure-posterizarr.py" "$STORAGE_PATH"; then
            print_success "Posterizarr configuration completed!"
            print_info "🎨 Posterizarr available at: http://localhost:${POSTERIZARR_PORT:-5060}"
        else
            print_warning "Posterizarr configuration had some issues, manual setup may be needed"
        fi
    fi

    # Configure CineSync if enabled
    if [ "$ENABLE_CINESYNC" = "true" ]; then
        print_info "🎬 Configuring CineSync media synchronization..."
        show_quick_progress "Setting up media organization automation..." 10
        if python3 "$SCRIPT_DIR/configure-cinesync.py" "$STORAGE_PATH"; then
            print_success "CineSync configuration completed!"
            print_info "🎬 CineSync media organization is now automated"
        else
            print_warning "CineSync configuration had some issues, manual setup may be needed"
        fi
    fi

    # Configure Placeholdarr if enabled
    if [ "$ENABLE_PLACEHOLDARR" = "true" ]; then
        print_info "📄 Configuring Placeholdarr file management..."
        show_quick_progress "Setting up placeholder file automation..." 10
        if python3 "$SCRIPT_DIR/configure-placeholdarr.py" "$STORAGE_PATH"; then
            print_success "Placeholdarr configuration completed!"
            print_info "📄 Placeholdarr file management is now automated"
        else
            print_warning "Placeholdarr configuration had some issues, manual setup may be needed"
        fi
    fi

    # Configure Decypharr if enabled
    if [ "$ENABLE_DECYPHARR" = "true" ]; then
        print_info "⚡ Configuring Decypharr blackhole processing..."
        show_quick_progress "Setting up debrid service integration..." 12
        if python3 "$SCRIPT_DIR/configure-decypharr.py" "$STORAGE_PATH"; then
            print_success "Decypharr configuration completed!"
            print_info "⚡ Decypharr debrid blackhole processing is now automated"
            print_info "🌐 Decypharr Web UI available at: http://localhost:${DECYPHARR_PORT:-8282}"
        else
            print_warning "Decypharr configuration had some issues, manual setup may be needed"
        fi
    fi

    # Configure Zurg if enabled
    if [ "$ENABLE_ZURG" = "true" ]; then
        print_info "💾 Configuring Zurg Real-Debrid filesystem..."
        show_quick_progress "Setting up rclone mount and WebDAV..." 15
        if python3 "$SCRIPT_DIR/configure-zurg.py" "$STORAGE_PATH"; then
            print_success "Zurg configuration completed!"
            print_info "💾 Zurg Real-Debrid filesystem is now automated"
            print_info "🌐 Zurg WebDAV available at: http://localhost:${ZURG_PORT:-9999}"
            print_info "📁 Mount point: /mnt/zurg (requires rclone mount)"
        else
            print_warning "Zurg configuration had some issues, manual setup may be needed"
        fi
    fi

    print_success "Service configuration completed!"
}
# Generate homepage.yaml widgets for all enabled services
configure_homepage_widgets() {
    print_step "🖥️  Configuring Homepage widgets..."
    show_quick_progress "Generating homepage dashboard configuration..." 8
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
    if [ "$ENABLE_PD_ZURG" = "true" ]; then
        echo "  - name: PD_Zurg" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_CLI_DEBRID" = "true" ]; then
        echo "  - name: cli_debrid" >> "$homepage_yaml"
        echo "    url: cli" >> "$homepage_yaml"
    fi
    if [ "$ENABLE_DECYPHARR" = "true" ]; then
        echo "  - name: Decypharr" >> "$homepage_yaml"
        echo "    url: http://localhost:8282" >> "$homepage_yaml"
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
        echo "    url: http://localhost:8182" >> "$homepage_yaml"
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

# Add application connection to Prowlarr (Radarr/Sonarr)
add_prowlarr_app_connection() {
    local app_name=$1
    local app_api_key=$2
    local app_port=$3
    local prowlarr_api_key=$(get_prowlarr_api_key)
    
    if [ -n "$app_api_key" ] && [ -n "$prowlarr_api_key" ]; then
        print_info "Adding $app_name connection to Prowlarr..."
        
        # Determine app type and settings
        local app_implementation=""
        local app_base_url=""
        case "$app_name" in
            "radarr")
                app_implementation="Radarr"
                app_base_url="http://surge-radarr:7878"
                ;;
            "sonarr")
                app_implementation="Sonarr"
                app_base_url="http://surge-sonarr:8989"
                ;;
            *)
                print_warning "Unknown application: $app_name"
                return 1
                ;;
        esac
        
        local app_data='{
            "enable": true,
            "name": "'$app_implementation'",
            "fields": [
                {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"},
                {"name": "baseUrl", "value": "'$app_base_url'"},
                {"name": "apiKey", "value": "'$app_api_key'"},
                {"name": "syncCategories", "value": [5000,5030,5040,5045,5050,5060,5070,5080]}
            ],
            "implementationName": "'$app_implementation'",
            "implementation": "'$app_implementation'",
            "configContract": "'$app_implementation'Settings",
            "tags": []
        }'
        
        curl -s -X POST "http://localhost:9696/api/v1/applications" \
            -H "Content-Type: application/json" \
            -H "X-Api-Key: $prowlarr_api_key" \
            -d "$app_data" > /dev/null
            
        if [ $? -eq 0 ]; then
            print_success "$app_name connection added to Prowlarr"
        else
            print_warning "Failed to add $app_name connection to Prowlarr"
        fi
    else
        print_warning "Missing API keys for $app_name connection to Prowlarr"
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
        print_info "🌐 Running RDT-Client comprehensive automation..."
        show_quick_progress "Configuring RDT-Client and Torrentio settings..." 12
        # Ensure RD_API_TOKEN is set from setup wizard
        if [ -z "$RD_API_TOKEN" ]; then
            print_warning "Real-Debrid API token not found in environment."
            read -p "Please enter your Real-Debrid API Token for Torrentio setup: " rd_token_fallback
            export RD_API_TOKEN="$rd_token_fallback"
        else
            export RD_API_TOKEN
        fi
        if [ -f "$SCRIPT_DIR/configure-rdt-torrentio.py" ]; then
            python3 "$SCRIPT_DIR/configure-rdt-torrentio.py" "$STORAGE_PATH"
            if [ $? -eq 0 ]; then
                print_success "RDT-Client and Torrentio automation completed successfully!"
            else
                print_warning "RDT-Client automation had some issues, manual configuration may be needed"
                # Fallback to old method
                configure_rdt_client_in_arr "radarr" "7878"
                configure_rdt_client_in_arr "sonarr" "8989"
            fi
        else
            # Fallback to old method
            configure_rdt_client_in_arr "radarr" "7878"
            configure_rdt_client_in_arr "sonarr" "8989"
        fi
    fi
}

# Configure NZBGet in *arr service
configure_nzbget_in_arr() {
    local service=$1
    local port=$2
    local api_key=$(get_arr_api_key "$service" "$port")
    # Use admin credentials for NZBGet
    local username="admin"
    local password="changeme"
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
                {"name": "username", "value": "admin"},
                {"name": "password", "value": "changeme"},
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
    
    wait_for_service "tautulli" "8182"
    
    print_info "Tautulli setup: http://localhost:8182/setup"
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
    show_quick_progress "Generating .env configuration..." 5
    


    cat > "$PROJECT_DIR/.env" << EOF
# ===========================================
# SURGE CONFIGURATION - Generated $(date)
# ===========================================

# GENERAL CONFIGURATION
TZ=$TIMEZONE
PUID=$PUID
PGID=$PGID

STORAGE_PATH=$STORAGE_PATH
CONFIG_DIR=\${STORAGE_PATH}/config

# DOWNLOAD CLIENT PATHS (Accessible by all containers)

# MEDIA SERVER SELECTION
MEDIA_SERVER=$MEDIA_SERVER
PLEX_SERVER_NAME=${PLEX_SERVER_NAME:-MyPlexServer}

# SERVICE CONFIGURATION
ENABLE_RADARR=${ENABLE_RADARR:-true}
ENABLE_SONARR=${ENABLE_SONARR:-true}
ENABLE_BAZARR=${ENABLE_BAZARR:-true}
ENABLE_PROWLARR=${ENABLE_PROWLARR:-true}
ENABLE_NZBGET=${ENABLE_NZBGET:-true}
ENABLE_RDT_CLIENT=${ENABLE_RDT_CLIENT:-false}
ENABLE_ZURG=${ENABLE_ZURG:-false}
ENABLE_CLI_DEBRID=${ENABLE_CLI_DEBRID:-false}
ENABLE_DECYPHARR=${ENABLE_DECYPHARR:-false}
ENABLE_KOMETA=${ENABLE_KOMETA:-true}
ENABLE_POSTERIZARR=${ENABLE_POSTERIZARR:-true}
ENABLE_OVERSEERR=${ENABLE_OVERSEERR:-true}
ENABLE_TAUTULLI=${ENABLE_TAUTULLI:-true}
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
DECYPHARR_PORT=8282
TAUTULLI_PORT=8182
OVERSEERR_PORT=5055
RDT_CLIENT_PORT=6500
ZURG_PORT=9999
KOMETA_PORT=5556
PLEX_PORT=${PLEX_PORT:-32400}
EMBY_PORT=${EMBY_PORT:-8096}
JELLYFIN_PORT=${JELLYFIN_PORT:-8096}
GAPS_PORT=${GAPS_PORT:-8484}

# AUTOMATION
WATCHTOWER_INTERVAL=${WATCHTOWER_INTERVAL:-86400}
ASSET_PROCESSING_SCHEDULE="${ASSET_PROCESSING_SCHEDULE:-0 2 * * *}"

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
# Note: NZBGET_PASS should be set in .env file or will be auto-generated
NZBGET_PASS=${NZBGET_PASS:-}
RD_API_TOKEN=${RD_API_TOKEN:-}
PD_ZURG_DOWNLOADS_PATH=${PD_ZURG_DOWNLOADS_PATH:-}
AD_API_TOKEN=${AD_API_TOKEN:-}
PREMIUMIZE_API_TOKEN=${PREMIUMIZE_API_TOKEN:-}
RD_USERNAME=${RD_USERNAME:-}

# DEPLOYMENT TYPE
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-full}
INSTALL_TYPE=${INSTALL_TYPE:-auto}

# GENERATED TIMESTAMP
CONFIG_GENERATED="$(date '+%Y-%m-%d %H:%M:%S')"
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

# Create per-container directory structure
create_service_directories() {
    print_step "Creating per-service directory structure..."
    show_quick_progress "Setting up individual service directories..." 12

    # List of services and their required subfolders
    declare -A service_folders
    service_folders=(
        [Bazarr]="config media"
        [Radarr]="config media"
        [Sonarr]="config media"
        [Prowlarr]="config"
        [NZBGet]="config downloads"
        [RDT-Client]="config downloads"
        [Zurg]="config downloads"
        [cli_debrid]="config"
        [Decypharr]="config"
        [Kometa]="config"
        [Posterizarr]="config"
        [Overseerr]="config"
        [Tautulli]="config"
        [CineSync]="config"
        [Placeholdarr]="config"
        [GAPS]="config"
        [Plex]="config media"
        [Emby]="config media"
        [Jellyfin]="config media"
    )

    # Only create folders for enabled services
    for service in "Bazarr" "Radarr" "Sonarr" "Prowlarr" "NZBGet" "RDT-Client" "Zurg" "cli_debrid" "Decypharr" "Kometa" "Posterizarr" "Overseerr" "Tautulli" "CineSync" "Placeholdarr" "GAPS"; do
        var_name="ENABLE_${service^^}"
        var_name="${var_name//-/_}"
        # shellcheck disable=SC2154
        if [ "${!var_name}" = "true" ]; then
            for sub in ${service_folders[$service]}; do
                mkdir -p "$STORAGE_PATH/$service/$sub"
            done
        fi
    done

    # Always create media server folders for the selected server
    case "$MEDIA_SERVER" in
        plex|Plex)
            mkdir -p "$STORAGE_PATH/Plex/config" "$STORAGE_PATH/Plex/media"
            ;;
        emby|Emby)
            mkdir -p "$STORAGE_PATH/Emby/config" "$STORAGE_PATH/Emby/media"
            ;;
        jellyfin|Jellyfin)
            mkdir -p "$STORAGE_PATH/Jellyfin/config" "$STORAGE_PATH/Jellyfin/media"
            ;;
    esac

    # Set permissions
    sudo chown -R "$PUID:$PGID" "$STORAGE_PATH"
    print_success "Per-service directory structure created at $STORAGE_PATH"
}

# Create directory structure (legacy, for shared folders)
create_directories() {
    print_step "Creating directory structure..."
    # Create shared folders for media, downloads, config, logs
    sudo mkdir -p "$STORAGE_PATH"/{media/{movies,tv,music},downloads,config,logs}
    sudo chown -R "$PUID:$PGID" "$STORAGE_PATH"
    print_success "Directory structure created at $STORAGE_PATH"
}

# Create initial service configurations
create_service_configs() {
    print_step "Creating initial service configurations..."
    show_quick_progress "Preparing configuration templates..." 10
    
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
    print_warning "Default credentials for all services is set to:"
    echo "    Username: admin"
    echo "    Password: password"
    print_warning "It is strongly advised to change these credentials after setup for security."
    echo ""
    
    print_info "Would you like to deploy Surge now? (y/n)"
    read -r deploy_now
    
    if [ "$deploy_now" = "y" ] || [ "$deploy_now" = "Y" ]; then
        deploy_stack "$MEDIA_SERVER"
        # Ensure Prowlarr indexers are configured after deployment
        if [ "$ENABLE_PROWLARR" = "true" ]; then
            connect_prowlarr_to_arr_services
        fi
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
        
        if [ "$ENABLE_ZURG" = "true" ]; then
            echo "   - Zurg: http://localhost:9999"
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
        print_step "🚀 Deploying Surge stack..."
        show_progress_bar "Starting containers and initializing services..." 45
        bash "$SCRIPT_DIR/deploy.sh" "$media_server"
        
        if [ $? -eq 0 ]; then
            print_success "Surge stack deployed successfully!"
            
            # Run comprehensive post-deployment configuration
            print_step "Running post-deployment configuration..."
            show_progress_bar "Connecting services and configuring automation..." 90
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
    
    if [ "$ENABLE_ZURG" = "true" ]; then
        echo "  🗂️  Zurg (Real-Debrid Filesystem): http://localhost:9999"
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
        echo "  📈 Tautulli (Analytics): http://localhost:8182"
    fi
    
    if [ "$ENABLE_POSTERIZARR" = "true" ]; then
        echo "  🖼️  Posterizarr (Posters): http://localhost:9876"
    fi
    
    echo ""
    print_info "🔧 Automatic Configuration Completed:"
    if [ -n "$RD_API_TOKEN" ]; then
        echo "  ✅ Torrentio indexer auto-configured with your Real-Debrid token"
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
    
    # Check if already initialized (unless --reconfigure is specified)
    check_first_run "$@"
    
    # Check for configuration updates if already exists
    detect_new_variables

    # Parse arguments for reconfigure and installation type
    RECONFIGURE_MODE=false
    INSTALL_TYPE=""
    
    # Check all arguments for flags
    for arg in "$@"; do
        case "$arg" in
            --reconfigure)
                RECONFIGURE_MODE=true
                ;;
            --auto)
                INSTALL_TYPE="auto"
                ;;
            --custom)
                INSTALL_TYPE="custom"
                ;;
        esac
    done

    # If no config exists or user chose to reconfigure, gather preferences
    if [ ! -f "$PROJECT_DIR/.env" ] || [ "$RECONFIGURE_MODE" = "true" ]; then
        # Handle installation type selection
        if [ "$INSTALL_TYPE" = "auto" ]; then
            INSTALL_TYPE="auto"
        elif [ "$INSTALL_TYPE" = "custom" ]; then
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
        
        # Export all ENABLE_* variables for directory creation
        export ENABLE_BAZARR ENABLE_RADARR ENABLE_SONARR ENABLE_PROWLARR ENABLE_NZBGET ENABLE_RDT_CLIENT ENABLE_ZURG ENABLE_CLI_DEBRID ENABLE_DECYPHARR ENABLE_KOMETA ENABLE_POSTERIZARR ENABLE_OVERSEERR ENABLE_TAUTULLI ENABLE_CINESYNC ENABLE_PLACEHOLDARR ENABLE_GAPS

        # Create per-service directories (now STORAGE_PATH is set)
        create_service_directories
        # Create shared directories (legacy, for backwards compatibility)
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
