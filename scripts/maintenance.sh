#!/bin/bash

# ===========================================
# SURGE MAINTENANCE SCRIPT
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

# System cleanup
cleanup_system() {
    print_info "Performing system cleanup..."
    
    cd "$PROJECT_DIR"
    
    # Remove stopped containers
    print_info "Removing stopped containers..."
    docker container prune -f
    
    # Remove unused images
    print_info "Removing unused images..."
    docker image prune -f
    
    # Remove unused volumes (with confirmation)
    print_warning "This will remove unused Docker volumes. Continue? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        docker volume prune -f
    fi
    
    # Remove unused networks
    print_info "Removing unused networks..."
    docker network prune -f
    
    print_success "System cleanup completed!"
}

# Health check
health_check() {
    print_info "Performing health check..."
    
    cd "$PROJECT_DIR"
    
    # Check container status
    print_info "Container status:"
    docker compose ps
    
    echo ""
    
    # Check disk usage
    print_info "Disk usage:"
    df -h
    
    echo ""
    
    # Check Docker system info
    print_info "Docker system info:"
    docker system df
    
    print_success "Health check completed!"
}

# Restart all services
restart_all() {
    print_info "Restarting all Surge services..."
    
    cd "$PROJECT_DIR"
    docker compose restart
    
    print_success "All services restarted!"
}

# View logs
view_logs() {
    local service=${1:-}
    
    cd "$PROJECT_DIR"
    
    if [ -n "$service" ]; then
        print_info "Showing logs for $service..."
        docker compose logs -f "$service"
    else
        print_info "Showing logs for all services..."
        docker compose logs -f
    fi
}

# Show service status
show_status() {
    print_info "Service status:"
    
    cd "$PROJECT_DIR"
    docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    print_info "Resource usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
}

# Reset service
reset_service() {
    local service=$1
    
    if [ -z "$service" ]; then
        print_error "Service name required"
        exit 1
    fi
    
    print_warning "This will reset $service (remove container and restart). Continue? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        cd "$PROJECT_DIR"
        docker compose rm -s -f "$service"
        docker compose up -d "$service"
        print_success "$service has been reset!"
    else
        print_info "Reset cancelled."
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  cleanup           - Clean up Docker system (containers, images, volumes)"
    echo "  health            - Perform health check on all services"
    echo "  restart           - Restart all services"
    echo "  logs [service]    - View logs (all services or specific service)"
    echo "  status            - Show service status and resource usage"
    echo "  reset <service>   - Reset a specific service"
    echo ""
    echo "Examples:"
    echo "  $0 cleanup        # Clean up Docker system"
    echo "  $0 logs radarr    # View Radarr logs"
    echo "  $0 reset plex     # Reset Plex container"
    echo ""
}

# Main function
main() {
    case ${1:-} in
        cleanup)
            cleanup_system
            ;;
        health)
            health_check
            ;;
        restart)
            restart_all
            ;;
        logs)
            view_logs "$2"
            ;;
        status)
            show_status
            ;;
        reset)
            reset_service "$2"
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
