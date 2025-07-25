#!/bin/bash

# ===========================================
# SURGE COMMAND-LINE TOOL ACCESS
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Load environment
load_environment() {
    if [ -f "$PROJECT_DIR/.env" ]; then
        export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs)
    else
        print_error ".env file not found. Run './surge setup' first."
        exit 1
    fi
}

# Execute command in service container
exec_in_service() {
    local service=$1
    shift
    local command="$*"
    
    cd "$PROJECT_DIR"
    
    case $service in
        scanly)
            print_info "Running Scanly command: $command"
            docker run --rm -it \
                --name surge-scanly-exec \
                --network surge-network \
                -v scanly-config:/config \
                -v "${MOVIES_DIR:-./data/media/movies}":/movies \
                -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
                -v surge_shared-assets:/assets \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                amcgready/scanly:latest $command
            ;;
        kometa)
            print_info "Running Kometa command: $command"
            docker run --rm -it \
                --name surge-kometa-exec \
                --network surge-network \
                -v surge_kometa-config:/config \
                -v surge_shared-assets:/assets \
                -v "${MOVIES_DIR:-./data/media/movies}":/movies \
                -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                -e KOMETA_CONFIG=/config/config.yml \
                kometateam/kometa:latest $command
            ;;
        cli-debrid)
            print_info "Running cli_debrid command: $command"
            docker run --rm -it \
                --name surge-cli-debrid-exec \
                --network surge-network \
                -v cli-debrid-config:/app/config \
                -v "${DOWNLOADS_DIR:-./data/downloads}":/downloads \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                -e RD_API_KEY="${RD_API_TOKEN}" \
                -e AD_API_KEY="${AD_API_TOKEN:-}" \
                -e PREMIUMIZE_API_KEY="${PREMIUMIZE_API_TOKEN:-}" \
                godver3/cli_debrid:latest $command
            ;;
        radarr|sonarr|bazarr|nzbget|tautulli|plex|emby|jellyfin|decypharr)
            print_info "Connecting to $service container..."
            docker exec -it "surge-$service" ${command:-/bin/bash}
            ;;
        *)
            print_error "Unknown service: $service"
            show_usage
            exit 1
            ;;
    esac
}

# Interactive shell access
shell_access() {
    local service=$1
    
    print_info "Opening interactive shell in $service..."
    
    case $service in
        scanly)
            docker run --rm -it \
                --name surge-scanly-shell \
                --network surge-network \
                -v scanly-config:/config \
                -v "${MOVIES_DIR:-./data/media/movies}":/movies \
                -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
                -v surge_shared-assets:/assets \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                --entrypoint /bin/bash \
                amcgready/scanly:latest
            ;;
        *)
            docker exec -it "surge-$service" /bin/bash
            ;;
    esac
}

# Run Scanly with common commands
run_scanly() {
    local action=${1:-help}
    
    case $action in
        scan)
            print_info "Running Scanly scan..."
            exec_in_service scanly "python3 main.py scan"
            ;;
        organize)
            print_info "Running Scanly organize..."
            exec_in_service scanly "python3 main.py organize"
            ;;
        config)
            print_info "Opening Scanly configuration..."
            exec_in_service scanly "python3 main.py config"
            ;;
        shell)
            print_info "Opening Scanly interactive shell..."
            shell_access scanly
            ;;
        help|*)
            echo "Scanly Commands:"
            echo "  ./surge exec scanly scan      - Scan media files"
            echo "  ./surge exec scanly organize  - Organize media files"
            echo "  ./surge exec scanly config    - Configure Scanly"
            echo "  ./surge exec scanly shell     - Interactive shell"
            echo "  ./surge exec scanly 'python3 main.py --help'  - Full help"
            ;;
    esac
}

# Show available services
show_services() {
    print_info "Available services:"
    echo ""
    echo "Command-line tools:"
    echo "  scanly    - Media scanner and organizer"
    echo "  kometa    - Metadata and collection manager"
    echo ""
    echo "Running services (shell access):"
    echo "  radarr    - Movie management"
    echo "  sonarr    - TV management"
    echo "  bazarr    - Subtitle management"
    echo "  nzbget    - Usenet downloader"
    echo "  tautulli  - Media server statistics"
    echo "  plex      - Plex Media Server (if deployed)"
    echo "  emby      - Emby Server (if deployed)"
    echo "  jellyfin  - Jellyfin Server (if deployed)"
    echo ""
    echo "Examples:"
    echo "  ./surge exec scanly scan              # Run Scanly scan"
    echo "  ./surge exec scanly shell             # Interactive Scanly shell"
    echo "  ./surge exec kometa '--run'           # Run Kometa"
    echo "  ./surge exec radarr                   # Shell access to Radarr"
    echo ""
}

# Show usage
show_usage() {
    echo "Usage: $0 <service> [command]"
    echo ""
    echo "Services:"
    echo "  scanly [scan|organize|config|shell]  - Scanly media scanner"
    echo "  kometa [command]                     - Kometa metadata manager"
    echo "  <service>                            - Shell access to running service"
    echo ""
    echo "Examples:"
    echo "  $0 scanly scan                       # Run Scanly scan"
    echo "  $0 scanly 'python3 main.py --help'  # Custom Scanly command"
    echo "  $0 kometa '--run'                    # Run Kometa"
    echo "  $0 radarr                            # Shell access to Radarr"
    echo ""
    echo "Available services:"
    show_services
}

# Main function
main() {
    local service=${1:-}
    
    if [ -z "$service" ]; then
        show_usage
        exit 1
    fi
    
    load_environment
    
    case $service in
        scanly)
            if [ $# -eq 1 ]; then
                run_scanly help
            elif [ $# -eq 2 ]; then
                run_scanly "$2"
            else
                shift
                exec_in_service scanly "$*"
            fi
            ;;
        kometa)
            shift
            exec_in_service kometa "$*"
            ;;
        services)
            show_services
            ;;
        help|-h|--help)
            show_usage
            ;;
        *)
            if [ $# -eq 1 ]; then
                shell_access "$service"
            else
                shift
                exec_in_service "$service" "$*"
            fi
            ;;
    esac
}

# Run main function
main "$@"
