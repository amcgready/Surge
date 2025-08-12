#!/usr/bin/env python3
"""
CineSync Configuration Script for Surge

Automatically configures CineSync media synchronization service including:
- Environment file generation with optimized settings
- Directory structure validation and creation
- TMDB API integration for metadata
- Integration with Radarr/Sonarr for library organization
- Custom folder organization settings
- Resolution-based organization options
- Anime and family content separation
"""

import os
import sys
import time
import subprocess
from pathlib import Path
from typing import List

class SurgeCineSyncConfigurator:
    def __init__(self):
        """Initialize CineSync configurator."""
        self.project_root = Path(__file__).parent.parent
        self.storage_path = os.environ.get('STORAGE_PATH')
        if not self.storage_path:
            raise RuntimeError("STORAGE_PATH environment variable is required but not set. Please run './surge setup' or export STORAGE_PATH before running this script.")

        # Load environment variables
        self.load_env()

        # Configuration paths
        self.config_dir = Path(self.storage_path) / "Cinesync" / "config"
        self.env_file = self.config_dir / ".env"
        self.template_file = self.project_root / "configs" / "cinesync-env.template"

        # Service detection
        self.enabled_services = self.detect_enabled_services()

        # Configuration settings
        self.config = {}
        self.api_keys = {}

        self.log("CineSync Configurator initialized", "INFO")
        self.log(f"Storage path: {self.storage_path}", "INFO")
        self.log(f"Config directory: {self.config_dir}", "INFO")

    # _read_storage_path_from_env removed: STORAGE_PATH must be set in environment

    # def find_storage_path(self) -> str:
    #     Deprecated: No fallback to /opt/surge. STORAGE_PATH is required.

    def load_env(self):
        """Load environment variables from .env file."""
        env_file = self.project_root / '.env'
        if env_file.exists():
            with open(env_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        os.environ[key] = value

    def detect_enabled_services(self) -> List[str]:
        """Detect enabled services from environment variables."""
        services = []
        service_map = {
            'ENABLE_CINESYNC': 'cinesync',
            'ENABLE_RADARR': 'radarr',
            'ENABLE_SONARR': 'sonarr',
            'ENABLE_PLEX': 'plex',
            'ENABLE_EMBY': 'emby',
            'ENABLE_JELLYFIN': 'jellyfin'
        }
        
        for env_var, service in service_map.items():
            if os.environ.get(env_var, '').lower() == 'true':
                services.append(service)
        
        return services

    def log(self, message: str, level: str = "INFO"):
        """Log a message with timestamp and level."""
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        level_colors = {
            "INFO": "\033[94m",
            "SUCCESS": "\033[92m", 
            "WARNING": "\033[93m",
            "ERROR": "\033[91m"
        }
        
        color = level_colors.get(level, "\033[0m")
        reset_color = "\033[0m"
        
        print(f"{color}[{timestamp}] {level}: {message}{reset_color}")

    def create_directories(self) -> bool:
        """Create necessary directories for CineSync based on user configuration."""
        try:
            self.log("Creating CineSync directory structure...", "INFO")

            # Create config directory (but NOT the .env file as a directory)
            if not self.config_dir.exists():
                self.config_dir.mkdir(parents=True, exist_ok=True)
            # If .env exists and is a directory, warn user
            if self.env_file.exists() and self.env_file.is_dir():
                self.log(f".env exists as a directory at {self.env_file}. Please remove it and re-run.", "ERROR")
                return False

            # Create media directories based on user configuration
            media_base = Path(self.storage_path) / "media"

            # Always create standard directories
            standard_dirs = [
                self.config.get('CUSTOM_MOVIE_FOLDER', 'Movies'),
                self.config.get('CUSTOM_SHOW_FOLDER', 'TV Series')
            ]

            # Add anime directories if enabled
            if self.config.get('ANIME_SEPARATION', 'true') == 'true':
                standard_dirs.extend([
                    self.config.get('CUSTOM_ANIME_MOVIE_FOLDER', 'Anime Movies'),
                    self.config.get('CUSTOM_ANIME_SHOW_FOLDER', 'Anime Series')
                ])

            # Add 4K directories if enabled
            if self.config.get('4K_SEPARATION', 'false') == 'true':
                standard_dirs.extend([
                    self.config.get('CUSTOM_4KMOVIE_FOLDER', '4K Movies'),
                    self.config.get('CUSTOM_4KSHOW_FOLDER', '4K Series')
                ])

            # Add kids directories if enabled
            if self.config.get('KIDS_SEPARATION', 'false') == 'true':
                standard_dirs.extend([
                    self.config.get('CUSTOM_KIDS_MOVIE_FOLDER', 'Kids Movies'),
                    self.config.get('CUSTOM_KIDS_SHOW_FOLDER', 'Kids Series')
                ])

            # Create each directory (skip .env)
            for dir_name in standard_dirs:
                # Prevent accidental creation of a directory named .env
                if dir_name == '.env':
                    self.log("Skipping creation of directory named .env (reserved for environment file)", "WARNING")
                    continue
                dir_path = media_base / dir_name
                dir_path.mkdir(parents=True, exist_ok=True)
                self.log(f"Created directory: {dir_path}", "SUCCESS")

            # Set proper permissions
            uid = int(os.environ.get('PUID', 1000))
            gid = int(os.environ.get('PGID', 1000))

            try:
                subprocess.run(['chown', '-R', f'{uid}:{gid}', str(self.config_dir)],
                             check=True, capture_output=True)
                self.log("Set directory permissions", "SUCCESS")
            except subprocess.CalledProcessError as e:
                self.log(f"Could not set permissions: {e}", "WARNING")

            return True

        except Exception as e:
            self.log(f"Error creating directories: {e}", "ERROR")
            return False

    def load_configuration_template(self) -> bool:
        """Load configuration template and merge with environment variables."""
        try:
            self.log("Loading CineSync configuration template...", "INFO")
            
            if not self.template_file.exists():
                self.log(f"Template file not found: {self.template_file}", "ERROR")
                return False
            
            # Load default configuration
            self.config = {
                # Directory Paths
                'SOURCE_DIR': os.environ.get('CINESYNC_SOURCE_DIR', f'{self.storage_path}/downloads/pd_zurg/__all__'),
                'DESTINATION_DIR': os.environ.get('CINESYNC_DESTINATION_DIR', f'{self.storage_path}/downloads/'),
                'USE_SOURCE_STRUCTURE': os.environ.get('CINESYNC_USE_SOURCE_STRUCTURE', 'false'),
                
                # Media Organization
                'CINESYNC_LAYOUT': os.environ.get('CINESYNC_LAYOUT', 'true'),
                'ANIME_SEPARATION': os.environ.get('CINESYNC_ANIME_SEPARATION', 'true'),
                '4K_SEPARATION': os.environ.get('CINESYNC_4K_SEPARATION', 'false'),
                'KIDS_SEPARATION': os.environ.get('CINESYNC_KIDS_SEPARATION', 'false'),
                
                # Custom Folders
                'CUSTOM_SHOW_FOLDER': os.environ.get('CINESYNC_CUSTOM_SHOW_FOLDER', 'TV Series'),
                'CUSTOM_4KSHOW_FOLDER': os.environ.get('CINESYNC_CUSTOM_4KSHOW_FOLDER', '4K Series'),
                'CUSTOM_ANIME_SHOW_FOLDER': os.environ.get('CINESYNC_CUSTOM_ANIME_SHOW_FOLDER', 'Anime Series'),
                'CUSTOM_MOVIE_FOLDER': os.environ.get('CINESYNC_CUSTOM_MOVIE_FOLDER', 'Movies'),
                'CUSTOM_4KMOVIE_FOLDER': os.environ.get('CINESYNC_CUSTOM_4KMOVIE_FOLDER', '4K Movies'),
                'CUSTOM_ANIME_MOVIE_FOLDER': os.environ.get('CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER', 'Anime Movies'),
                'CUSTOM_KIDS_MOVIE_FOLDER': os.environ.get('CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER', 'Kids Movies'),
                'CUSTOM_KIDS_SHOW_FOLDER': os.environ.get('CINESYNC_CUSTOM_KIDS_SHOW_FOLDER', 'Kids Series'),
                
                # Resolution Structure
                'SHOW_RESOLUTION_STRUCTURE': os.environ.get('CINESYNC_SHOW_RESOLUTION_STRUCTURE', 'false'),
                'MOVIE_RESOLUTION_STRUCTURE': os.environ.get('CINESYNC_MOVIE_RESOLUTION_STRUCTURE', 'false'),
                
                # Logging
                'LOG_LEVEL': os.environ.get('CINESYNC_LOG_LEVEL', 'INFO'),
                
                # Rclone Mount
                'RCLONE_MOUNT': os.environ.get('CINESYNC_RCLONE_MOUNT', 'false'),
                'MOUNT_CHECK_INTERVAL': os.environ.get('CINESYNC_MOUNT_CHECK_INTERVAL', '30'),
                
                # API Keys
                'TMDB_API_KEY': os.environ.get('CINESYNC_TMDB_API_KEY') or os.environ.get('TMDB_API_KEY', ''),
                'LANGUAGE': os.environ.get('CINESYNC_LANGUAGE', 'English'),
                
                # Metadata Settings
                'ANIME_SCAN': os.environ.get('CINESYNC_ANIME_SCAN', 'false'),
                'TMDB_FOLDER_ID': os.environ.get('CINESYNC_TMDB_FOLDER_ID', 'false'),
                'IMDB_FOLDER_ID': os.environ.get('CINESYNC_IMDB_FOLDER_ID', 'false'),
                'TVDB_FOLDER_ID': os.environ.get('CINESYNC_TVDB_FOLDER_ID', 'false'),
                
                # File Processing
                'RENAME_ENABLED': os.environ.get('CINESYNC_RENAME_ENABLED', 'false'),
                'MEDIAINFO_PARSER': os.environ.get('CINESYNC_MEDIAINFO_PARSER', 'false'),
                'RENAME_TAGS': os.environ.get('CINESYNC_RENAME_TAGS', 'Resolution'),
                
                # Collections
                'MOVIE_COLLECTION_ENABLED': os.environ.get('CINESYNC_MOVIE_COLLECTION_ENABLED', 'false'),
                
                # System Settings
                'PUID': os.environ.get('PUID', '1000'),
                'PGID': os.environ.get('PGID', '1000'),
                'TZ': os.environ.get('TZ', 'UTC')
            }
            
            # Validate source directory exists or can be created
            source_dir = Path(self.config['SOURCE_DIR'])
            if not source_dir.exists():
                self.log(f"Source directory doesn't exist, creating: {source_dir}", "WARNING")
                source_dir.mkdir(parents=True, exist_ok=True)
            
            # Validate destination directory
            dest_dir = Path(self.config['DESTINATION_DIR'])
            dest_dir.mkdir(parents=True, exist_ok=True)
            
            self.log("Configuration template loaded successfully", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error loading configuration template: {e}", "ERROR")
            return False

    def optimize_for_surge_environment(self) -> bool:
        """Optimize CineSync settings for Surge environment."""
        try:
            self.log("Optimizing CineSync for Surge environment...", "INFO")
            
            # Enable anime separation for comprehensive library organization
            if 'radarr' in self.enabled_services or 'sonarr' in self.enabled_services:
                self.config['ANIME_SEPARATION'] = 'true'
                self.log("Enabled anime separation for *arr integration", "SUCCESS")
            
            # Enable TMDB metadata if API key is available
            if self.config.get('TMDB_API_KEY'):
                self.config['TMDB_FOLDER_ID'] = 'true'
                self.config['IMDB_FOLDER_ID'] = 'true'
                self.config['RENAME_ENABLED'] = 'true'
                self.config['MEDIAINFO_PARSER'] = 'true'
                self.log("Enabled metadata features with TMDB API", "SUCCESS")
            
            # Optimize for media server integration
            media_servers = ['plex', 'emby', 'jellyfin']
            if any(server in self.enabled_services for server in media_servers):
                self.config['CINESYNC_LAYOUT'] = 'true'
                self.config['MOVIE_COLLECTION_ENABLED'] = 'true'
                self.log("Optimized layout for media server compatibility", "SUCCESS")
            
            # Set appropriate logging level
            self.config['LOG_LEVEL'] = 'INFO'
            
            return True
            
        except Exception as e:
            self.log(f"Error optimizing configuration: {e}", "ERROR")
            return False

    def generate_environment_file(self) -> bool:
        """Generate the CineSync environment file."""
        try:
            self.log("Generating CineSync environment file...", "INFO")
            
            # Generate environment file content
            env_content = []
            env_content.append("# CineSync Configuration - Auto-generated by Surge")
            env_content.append(f"# Generated on: {time.strftime('%Y-%m-%d %H:%M:%S')}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# Directory Paths")
            env_content.append("# ========================================")
            env_content.append(f"SOURCE_DIR={self.config['SOURCE_DIR']}")
            env_content.append(f"DESTINATION_DIR={self.config['DESTINATION_DIR']}")
            env_content.append(f"USE_SOURCE_STRUCTURE={self.config['USE_SOURCE_STRUCTURE']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# Media Organization Configuration")
            env_content.append("# ========================================")
            env_content.append(f"CINESYNC_LAYOUT={self.config['CINESYNC_LAYOUT']}")
            env_content.append(f"ANIME_SEPARATION={self.config['ANIME_SEPARATION']}")
            env_content.append(f"4K_SEPARATION={self.config['4K_SEPARATION']}")
            env_content.append(f"KIDS_SEPARATION={self.config['KIDS_SEPARATION']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# Custom Folder Names")
            env_content.append("# ========================================")
            env_content.append(f"CUSTOM_SHOW_FOLDER={self.config['CUSTOM_SHOW_FOLDER']}")
            env_content.append(f"CUSTOM_4KSHOW_FOLDER={self.config['CUSTOM_4KSHOW_FOLDER']}")
            env_content.append(f"CUSTOM_ANIME_SHOW_FOLDER={self.config['CUSTOM_ANIME_SHOW_FOLDER']}")
            env_content.append(f"CUSTOM_MOVIE_FOLDER={self.config['CUSTOM_MOVIE_FOLDER']}")
            env_content.append(f"CUSTOM_4KMOVIE_FOLDER={self.config['CUSTOM_4KMOVIE_FOLDER']}")
            env_content.append(f"CUSTOM_ANIME_MOVIE_FOLDER={self.config['CUSTOM_ANIME_MOVIE_FOLDER']}")
            env_content.append(f"CUSTOM_KIDS_MOVIE_FOLDER={self.config['CUSTOM_KIDS_MOVIE_FOLDER']}")
            env_content.append(f"CUSTOM_KIDS_SHOW_FOLDER={self.config['CUSTOM_KIDS_SHOW_FOLDER']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# Resolution-Based Organization")
            env_content.append("# ========================================")
            env_content.append(f"SHOW_RESOLUTION_STRUCTURE={self.config['SHOW_RESOLUTION_STRUCTURE']}")
            env_content.append(f"MOVIE_RESOLUTION_STRUCTURE={self.config['MOVIE_RESOLUTION_STRUCTURE']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# API Integration")
            env_content.append("# ========================================")
            env_content.append(f"TMDB_API_KEY={self.config['TMDB_API_KEY']}")
            env_content.append(f"LANGUAGE={self.config['LANGUAGE']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# Metadata and Processing")
            env_content.append("# ========================================")
            env_content.append(f"ANIME_SCAN={self.config['ANIME_SCAN']}")
            env_content.append(f"TMDB_FOLDER_ID={self.config['TMDB_FOLDER_ID']}")
            env_content.append(f"IMDB_FOLDER_ID={self.config['IMDB_FOLDER_ID']}")
            env_content.append(f"TVDB_FOLDER_ID={self.config['TVDB_FOLDER_ID']}")
            env_content.append(f"RENAME_ENABLED={self.config['RENAME_ENABLED']}")
            env_content.append(f"MEDIAINFO_PARSER={self.config['MEDIAINFO_PARSER']}")
            env_content.append(f"RENAME_TAGS={self.config['RENAME_TAGS']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# Collections and Advanced Features")
            env_content.append("# ========================================")
            env_content.append(f"MOVIE_COLLECTION_ENABLED={self.config['MOVIE_COLLECTION_ENABLED']}")
            env_content.append("")
            
            env_content.append("# ========================================")
            env_content.append("# System Configuration")
            env_content.append("# ========================================")
            env_content.append(f"LOG_LEVEL={self.config['LOG_LEVEL']}")
            env_content.append(f"RCLONE_MOUNT={self.config['RCLONE_MOUNT']}")
            env_content.append(f"MOUNT_CHECK_INTERVAL={self.config['MOUNT_CHECK_INTERVAL']}")
            env_content.append("")
            env_content.append(f"# Docker user settings")
            env_content.append(f"PUID={self.config['PUID']}")
            env_content.append(f"PGID={self.config['PGID']}")
            env_content.append(f"TZ={self.config['TZ']}")
            
            # Write environment file
            with open(self.env_file, 'w') as f:
                f.write('\n'.join(env_content))
            
            self.log(f"Environment file created: {self.env_file}", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error generating environment file: {e}", "ERROR")
            return False

    def validate_configuration(self) -> bool:
        """Validate CineSync configuration."""
        try:
            self.log("Validating CineSync configuration...", "INFO")
            
            # Check required directories exist
            required_dirs = [
                self.config['SOURCE_DIR'],
                self.config['DESTINATION_DIR']
            ]
            
            for dir_path in required_dirs:
                if not os.path.exists(dir_path):
                    self.log(f"Required directory missing: {dir_path}", "ERROR")
                    return False
            
            # Check TMDB API key if metadata features are enabled
            if (self.config.get('TMDB_FOLDER_ID') == 'true' or 
                self.config.get('RENAME_ENABLED') == 'true'):
                if not self.config.get('TMDB_API_KEY'):
                    self.log("TMDB API key required for metadata features", "WARNING")
                    # Disable metadata features
                    self.config['TMDB_FOLDER_ID'] = 'false'
                    self.config['RENAME_ENABLED'] = 'false'
            
            # Validate custom folder names
            custom_folders = [
                self.config.get('CUSTOM_SHOW_FOLDER'),
                self.config.get('CUSTOM_MOVIE_FOLDER'),
                self.config.get('CUSTOM_ANIME_SHOW_FOLDER'),
                self.config.get('CUSTOM_ANIME_MOVIE_FOLDER')
            ]
            
            for folder in custom_folders:
                if folder and ('/' in folder or '\\' in folder):
                    self.log(f"Invalid folder name (contains path separators): {folder}", "ERROR")
                    return False
            
            self.log("Configuration validation completed", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error validating configuration: {e}", "ERROR")
            return False

    def test_configuration(self) -> bool:
        """Test CineSync configuration."""
        try:
            self.log("Testing CineSync configuration...", "INFO")
            
            # Test directory access
            source_dir = Path(self.config['SOURCE_DIR'])
            dest_dir = Path(self.config['DESTINATION_DIR'])
            
            # Test write access to destination
            test_file = dest_dir / '.cinesync_test'
            try:
                test_file.write_text("test")
                test_file.unlink()
                self.log("Destination directory write access confirmed", "SUCCESS")
            except Exception as e:
                self.log(f"Cannot write to destination directory: {e}", "ERROR")
                return False
            
            # Test source directory access
            if not source_dir.exists():
                self.log(f"Source directory doesn't exist: {source_dir}", "WARNING")
            elif not os.access(source_dir, os.R_OK):
                self.log(f"Cannot read from source directory: {source_dir}", "ERROR")
                return False
            else:
                self.log("Source directory access confirmed", "SUCCESS")
            
            # Test TMDB API if configured
            if self.config.get('TMDB_API_KEY'):
                try:
                    import requests
                    response = requests.get(
                        f"https://api.themoviedb.org/3/configuration",
                        params={'api_key': self.config['TMDB_API_KEY']},
                        timeout=10
                    )
                    if response.status_code == 200:
                        self.log("TMDB API key validation successful", "SUCCESS")
                    else:
                        self.log("TMDB API key validation failed", "WARNING")
                except Exception as e:
                    self.log(f"Could not test TMDB API: {e}", "WARNING")
            
            self.log("Configuration testing completed", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error testing configuration: {e}", "ERROR")
            return False

    def display_configuration_summary(self):
        """Display a summary of the CineSync configuration."""
        self.log("=== CineSync Configuration Summary ===", "INFO")
        
        print(f"\n📁 Directory Configuration:")
        print(f"   Source: {self.config['SOURCE_DIR']}")
        print(f"   Destination: {self.config['DESTINATION_DIR']}")
        print(f"   Use Source Structure: {self.config['USE_SOURCE_STRUCTURE']}")
        
        print(f"\n🎬 Organization Settings:")
        print(f"   CineSync Layout: {self.config['CINESYNC_LAYOUT']}")
        print(f"   Anime Separation: {self.config['ANIME_SEPARATION']}")
        print(f"   4K Separation: {self.config['4K_SEPARATION']}")
        print(f"   Kids Separation: {self.config['KIDS_SEPARATION']}")
        
        print(f"\n📂 Media Library Folders:")
        print(f"   Movies: {self.config['CUSTOM_MOVIE_FOLDER']}")
        print(f"   TV Shows: {self.config['CUSTOM_SHOW_FOLDER']}")
        
        if self.config.get('ANIME_SEPARATION') == 'true':
            print(f"   Anime Movies: {self.config['CUSTOM_ANIME_MOVIE_FOLDER']}")
            print(f"   Anime Shows: {self.config['CUSTOM_ANIME_SHOW_FOLDER']}")
        
        if self.config.get('4K_SEPARATION') == 'true':
            print(f"   4K Movies: {self.config['CUSTOM_4KMOVIE_FOLDER']}")
            print(f"   4K Shows: {self.config['CUSTOM_4KSHOW_FOLDER']}")
        
        if self.config.get('KIDS_SEPARATION') == 'true':
            print(f"   Kids Movies: {self.config['CUSTOM_KIDS_MOVIE_FOLDER']}")
            print(f"   Kids Shows: {self.config['CUSTOM_KIDS_SHOW_FOLDER']}")
        
        print(f"\n🔧 Advanced Features:")
        print(f"   Resolution Structure: {self.config['SHOW_RESOLUTION_STRUCTURE']}")
        print(f"   TMDB Integration: {'✓' if self.config.get('TMDB_API_KEY') else '✗'}")
        print(f"   Metadata Parsing: {self.config['TMDB_FOLDER_ID']}")
        print(f"   File Renaming: {self.config['RENAME_ENABLED']}")
        print(f"   Collections: {self.config['MOVIE_COLLECTION_ENABLED']}")
        
        print(f"\n📄 Files Generated:")
        print(f"   Environment File: {self.env_file}")
        
        enabled_features = []
        if self.config.get('ANIME_SEPARATION') == 'true':
            enabled_features.append("Anime separation")
        if self.config.get('4K_SEPARATION') == 'true':
            enabled_features.append("4K separation")
        if self.config.get('KIDS_SEPARATION') == 'true':
            enabled_features.append("Kids content separation")
        if self.config.get('TMDB_API_KEY'):
            enabled_features.append("TMDB metadata integration")
        if self.config.get('SHOW_RESOLUTION_STRUCTURE') == 'true':
            enabled_features.append("Resolution-based organization")
        
        if enabled_features:
            print(f"\n✅ Active Features:")
            for feature in enabled_features:
                print(f"   • {feature}")
        
        print(f"\n🚀 Next Steps:")
        print(f"   1. Restart the CineSync container to apply settings")
        print(f"   2. Monitor logs for any processing issues") 
        print(f"   3. Verify media organization in destination folders")
        
        # Show folder structure that will be created
        print(f"\n📂 Directory Structure Created:")
        folders_created = [self.config['CUSTOM_MOVIE_FOLDER'], self.config['CUSTOM_SHOW_FOLDER']]
        
        if self.config.get('ANIME_SEPARATION') == 'true':
            folders_created.extend([self.config['CUSTOM_ANIME_MOVIE_FOLDER'], self.config['CUSTOM_ANIME_SHOW_FOLDER']])
        if self.config.get('4K_SEPARATION') == 'true':
            folders_created.extend([self.config['CUSTOM_4KMOVIE_FOLDER'], self.config['CUSTOM_4KSHOW_FOLDER']])
        if self.config.get('KIDS_SEPARATION') == 'true':
            folders_created.extend([self.config['CUSTOM_KIDS_MOVIE_FOLDER'], self.config['CUSTOM_KIDS_SHOW_FOLDER']])
        
        for folder in sorted(set(folders_created)):
            print(f"   {self.config['DESTINATION_DIR']}/{folder}/")
        
        if not enabled_features:
            print(f"\n💡 Tip: You can enable more organization features by reconfiguring CineSync")

def main():
    """Main execution function."""
    configurator = SurgeCineSyncConfigurator()
    
    try:
        # Configuration process
        if not configurator.load_configuration_template():
            sys.exit(1)
        
        if not configurator.optimize_for_surge_environment():
            sys.exit(1)
        
        if not configurator.validate_configuration():
            sys.exit(1)
        
        # Create directories based on user configuration
        if not configurator.create_directories():
            sys.exit(1)
        
        if not configurator.generate_environment_file():
            sys.exit(1)
        
        if not configurator.test_configuration():
            sys.exit(1)
        
        configurator.display_configuration_summary()
        
        configurator.log("CineSync configuration completed successfully!", "SUCCESS")
        return 0
        
    except KeyboardInterrupt:
        configurator.log("Configuration interrupted by user", "WARNING")
        return 1
    except Exception as e:
        configurator.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
