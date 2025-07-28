#!/bin/bash

# ===========================================
# SURGE ASSET PROCESSING TRIGGER
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

run_sequential_processing() {
    print_info "Starting sequential asset processing..."
    
    cd "$PROJECT_DIR"
    
    # Load environment
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs)
    fi
    
    # Step 1: ImageMaid
    print_info "Step 1/3: Running ImageMaid..."
    docker run --rm --name surge-imagemaid-manual \
        --network surge-network \
        -v surge_imagemaid-config:/config \
        -v surge_shared-assets:/assets \
        -v surge_shared-logs:/logs \
        -v "${MOVIES_DIR:-./data/media/movies}":/movies \
        -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
        -e PUID="${PUID:-1000}" \
        -e PGID="${PGID:-1000}" \
        -e TZ="${TZ:-UTC}" \
        kometateam/imagemaid:latest || {
        print_error "ImageMaid failed"
        exit 1
    }
    print_success "ImageMaid completed"
    
    # Step 3: Kometa
    print_info "Step 3/3: Running Kometa..."
    docker run --rm --name surge-kometa-manual \
        --network surge-network \
        -v surge_kometa-config:/config \
        -v surge_shared-assets:/assets \
        -v surge_shared-logs:/config/logs \
        -v "${MOVIES_DIR:-./data/media/movies}":/movies \
        -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
        -e PUID="${PUID:-1000}" \
        -e PGID="${PGID:-1000}" \
        -e TZ="${TZ:-UTC}" \
        -e KOMETA_CONFIG=/config/config.yml \
        kometateam/kometa:latest || {
        print_error "Kometa failed"
        exit 1
    }
    print_success "Kometa completed"
    
    print_success "Sequential asset processing completed successfully!"
}

run_individual_service() {
    local service=$1
    
    print_info "Running $service individually..."
    
    cd "$PROJECT_DIR"
    
    # Load environment
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs)
    fi
    
    case $service in
        imagemaid)
            docker run --rm --name surge-imagemaid-individual \
                --network surge-network \
                -v surge_imagemaid-config:/config \
                -v surge_shared-assets:/assets \
                -v surge_shared-logs:/logs \
                -v "${MOVIES_DIR:-./data/media/movies}":/movies \
                -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                kometateam/imagemaid:latest
            ;;
        posterizarr)
            docker run --rm --name surge-posterizarr-individual \
                --network surge-network \
                -v surge_posterizarr-config:/config \
                -v surge_shared-assets:/assets \
                -v surge_shared-logs:/logs \
                -v "${MOVIES_DIR:-./data/media/movies}":/movies \
                -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                fscorrupt/posterizarr:latest
            ;;
        kometa)
            docker run --rm --name surge-kometa-individual \
                --network surge-network \
                -v surge_kometa-config:/config \
                -v surge_shared-assets:/assets \
                -v surge_shared-logs:/config/logs \
                -v "${MOVIES_DIR:-./data/media/movies}":/movies \
                -v "${TV_SHOWS_DIR:-./data/media/tv}":/tv \
                -e PUID="${PUID:-1000}" \
                -e PGID="${PGID:-1000}" \
                -e TZ="${TZ:-UTC}" \
                -e KOMETA_CONFIG=/config/config.yml \
                kometateam/kometa:latest
            ;;
        *)
            print_error "Unknown service: $service"
            print_info "Available services: imagemaid, posterizarr, kometa"
            exit 1
            ;;
    esac
    
    print_success "$service completed"
}

show_usage() {
    echo "Usage: $0 [COMMAND] [SERVICE]"
    echo ""
    echo "Commands:"
    echo "  sequence          - Run ImageMaid → Posterizarr → Kometa in sequence"
    echo "  run <service>     - Run individual service"
    echo "  schedule          - Show current schedule"
    echo "  logs              - Show processing logs"
    echo ""
    echo "Services:"
    echo "  imagemaid         - Clean up and optimize images"
    echo "  posterizarr       - Manage custom posters"
    echo "  kometa            - Update metadata and collections"
    echo ""
    echo "Examples:"
    echo "  $0 sequence       # Run full sequence"
    echo "  $0 run kometa     # Run only Kometa"
    echo "  $0 logs           # View processing logs"
    echo ""
}

show_schedule() {
    print_info "Current processing schedule:"
    echo "  Daily at 2:00 AM: ImageMaid → Posterizarr → Kometa"
    echo ""
    print_info "To modify schedule, edit ASSET_PROCESSING_SCHEDULE in .env"
    echo "  Current: ${ASSET_PROCESSING_SCHEDULE:-0 2 * * *}"
}

show_logs() {
    cd "$PROJECT_DIR"
    
    print_info "Recent processing logs:"
    docker run --rm \
        -v surge_shared-logs:/logs \
        alpine:latest \
        sh -c 'if [ -f /logs/scheduler.log ]; then tail -50 /logs/scheduler.log; else echo "No logs found"; fi'
}

# Main function
main() {
    case ${1:-} in
        sequence)
            run_sequential_processing
            ;;
        run)
            if [ -z "$2" ]; then
                print_error "Service name required"
                show_usage
                exit 1
            fi
            run_individual_service "$2"
            ;;
        schedule)
            show_schedule
            ;;
        logs)
            show_logs
            ;;
        -h|--help|"")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
