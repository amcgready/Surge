#!/bin/bash

# ===========================================
# CINESYNC FOLDER CONFIGURATION SCRIPT
# ===========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
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

# Source the configure_cinesync_organization function from first-time-setup.sh
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
    
    # Kids separation  
    read -p "Separate kids/family content into dedicated folders? [y/N]: " kids_separation
    CINESYNC_KIDS_SEPARATION=$([[ "$kids_separation" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    if [ "$CINESYNC_KIDS_SEPARATION" = "true" ]; then
        echo "  👶 Family content will be organized separately"
        read -p "    Kids TV folder name [Kids Series]: " kids_tv_name
        CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=${kids_tv_name:-"Kids Series"}
        
        read -p "    Kids movie folder name [Kids Movies]: " kids_movie_name
        CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=${kids_movie_name:-"Kids Movies"}
    fi
    
    # Standard folder names
    echo ""
    echo "📁 Standard Library Folders:"
    read -p "TV Shows folder name [TV Series]: " tv_folder_name
    CINESYNC_CUSTOM_SHOW_FOLDER=${tv_folder_name:-"TV Series"}
    
    read -p "Movies folder name [Movies]: " movie_folder_name
    CINESYNC_CUSTOM_MOVIE_FOLDER=${movie_folder_name:-"Movies"}
    
    # Advanced options
    echo ""
    echo "🔧 Advanced Organization:"
    read -p "Use resolution-based subfolders for TV shows? [y/N]: " show_resolution
    CINESYNC_SHOW_RESOLUTION_STRUCTURE=$([[ "$show_resolution" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    read -p "Use resolution-based subfolders for movies? [y/N]: " movie_resolution  
    CINESYNC_MOVIE_RESOLUTION_STRUCTURE=$([[ "$movie_resolution" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    read -p "Preserve original source folder structure? [y/N]: " source_structure
    CINESYNC_USE_SOURCE_STRUCTURE=$([[ "$source_structure" =~ ^[Yy]$ ]] && echo "true" || echo "false")
    
    # Set defaults for unset variables
    CINESYNC_ANIME_SEPARATION=${CINESYNC_ANIME_SEPARATION:-true}
    CINESYNC_4K_SEPARATION=${CINESYNC_4K_SEPARATION:-false}
    CINESYNC_KIDS_SEPARATION=${CINESYNC_KIDS_SEPARATION:-false}
    CINESYNC_CUSTOM_ANIME_SHOW_FOLDER=${CINESYNC_CUSTOM_ANIME_SHOW_FOLDER:-"Anime Series"}
    CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER=${CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER:-"Anime Movies"}
    CINESYNC_CUSTOM_4KSHOW_FOLDER=${CINESYNC_CUSTOM_4KSHOW_FOLDER:-"4K Series"}
    CINESYNC_CUSTOM_4KMOVIE_FOLDER=${CINESYNC_CUSTOM_4KMOVIE_FOLDER:-"4K Movies"}
    CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=${CINESYNC_CUSTOM_KIDS_SHOW_FOLDER:-"Kids Series"}
    CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=${CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER:-"Kids Movies"}
    CINESYNC_SHOW_RESOLUTION_STRUCTURE=${CINESYNC_SHOW_RESOLUTION_STRUCTURE:-false}
    CINESYNC_MOVIE_RESOLUTION_STRUCTURE=${CINESYNC_MOVIE_RESOLUTION_STRUCTURE:-false}
    CINESYNC_USE_SOURCE_STRUCTURE=${CINESYNC_USE_SOURCE_STRUCTURE:-false}
}

# Main function
main() {
    echo ""
    echo "🎬 CineSync Folder Configuration"
    echo "======================================"
    echo ""
    
    # Check if CineSync is enabled
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        print_error ".env file not found!"
        echo "Please run './surge setup' first."
        exit 1
    fi
    
    ENABLE_CINESYNC=$(grep "^ENABLE_CINESYNC=" "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '\n\r' || echo "false")
    
    if [ "$ENABLE_CINESYNC" != "true" ]; then
        print_warning "CineSync is not enabled in your configuration."
        echo ""
        read -p "Would you like to enable CineSync? [Y/n]: " enable_it
        
        if [[ ! "$enable_it" =~ ^[Nn]$ ]]; then
            sed -i "s/^ENABLE_CINESYNC=.*/ENABLE_CINESYNC=true/" "$PROJECT_DIR/.env"
            print_success "✅ CineSync enabled!"
        else
            print_info "CineSync remains disabled. Exiting."
            exit 0
        fi
    fi
    
    # Run the configuration
    configure_cinesync_organization
    
    # Update .env file with new settings
    print_info "Updating .env file with your CineSync configuration..."
    
    sed -i "s/^CINESYNC_ANIME_SEPARATION=.*/CINESYNC_ANIME_SEPARATION=$CINESYNC_ANIME_SEPARATION/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_4K_SEPARATION=.*/CINESYNC_4K_SEPARATION=$CINESYNC_4K_SEPARATION/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_KIDS_SEPARATION=.*/CINESYNC_KIDS_SEPARATION=$CINESYNC_KIDS_SEPARATION/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_SHOW_FOLDER=.*/CINESYNC_CUSTOM_SHOW_FOLDER=\"$CINESYNC_CUSTOM_SHOW_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_MOVIE_FOLDER=.*/CINESYNC_CUSTOM_MOVIE_FOLDER=\"$CINESYNC_CUSTOM_MOVIE_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_ANIME_SHOW_FOLDER=.*/CINESYNC_CUSTOM_ANIME_SHOW_FOLDER=\"$CINESYNC_CUSTOM_ANIME_SHOW_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER=.*/CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER=\"$CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_4KSHOW_FOLDER=.*/CINESYNC_CUSTOM_4KSHOW_FOLDER=\"$CINESYNC_CUSTOM_4KSHOW_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_4KMOVIE_FOLDER=.*/CINESYNC_CUSTOM_4KMOVIE_FOLDER=\"$CINESYNC_CUSTOM_4KMOVIE_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=.*/CINESYNC_CUSTOM_KIDS_SHOW_FOLDER=\"$CINESYNC_CUSTOM_KIDS_SHOW_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=.*/CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER=\"$CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER\"/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_SHOW_RESOLUTION_STRUCTURE=.*/CINESYNC_SHOW_RESOLUTION_STRUCTURE=$CINESYNC_SHOW_RESOLUTION_STRUCTURE/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_MOVIE_RESOLUTION_STRUCTURE=.*/CINESYNC_MOVIE_RESOLUTION_STRUCTURE=$CINESYNC_MOVIE_RESOLUTION_STRUCTURE/" "$PROJECT_DIR/.env"
    sed -i "s/^CINESYNC_USE_SOURCE_STRUCTURE=.*/CINESYNC_USE_SOURCE_STRUCTURE=$CINESYNC_USE_SOURCE_STRUCTURE/" "$PROJECT_DIR/.env"
    
    # Show configuration summary
    echo ""
    print_success "✅ CineSync Configuration Complete"
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
        echo "   📐 Resolution-based sub-folders: Enabled for TV shows"
    fi
    
    if [ "$CINESYNC_MOVIE_RESOLUTION_STRUCTURE" = "true" ]; then
        echo "   📐 Resolution-based sub-folders: Enabled for movies"
    fi
    
    if [ "$CINESYNC_USE_SOURCE_STRUCTURE" = "true" ]; then
        echo "   📋 Source structure preservation: Enabled"
    fi
    
    echo ""
    print_success "Configuration saved to .env file!"
    echo ""
    print_info "Next steps:"
    echo "  • Run './surge deploy plex' to deploy with your CineSync configuration"
    echo "  • CineSync will organize your media according to these settings"
    echo ""
}

# Run main function
main "$@"
