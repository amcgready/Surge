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
    def detect_enabled_services(self):
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
    def __init__(self):
        """Initialize CineSync configurator."""
        self.project_root = Path(__file__).parent.parent
        self.load_env()
        self.storage_path = os.environ.get('STORAGE_PATH')
        if not self.storage_path:
            raise RuntimeError("STORAGE_PATH environment variable is required but not set. Please run './surge setup' or export STORAGE_PATH before running this script.")
        self.config_dir = Path(self.storage_path) / "CineSync" / "config"
        self.env_file = self.config_dir / ".env"
        self.template_file = self.project_root / "configs" / "cinesync-env.template"
        self.enabled_services = self.detect_enabled_services()
        self.config = {
            # Directory Paths
            'SOURCE_DIR': os.environ.get('CINESYNC_SOURCE_DIR', f'{self.storage_path}/downloads/Decypharr/debrids'),
            'DESTINATION_DIR': os.environ.get('CINESYNC_DESTINATION_DIR', f'{self.storage_path}/downloads/CineSync'),
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
        self.api_keys = {}
        self.log("CineSync Configurator initialized", "INFO")
        self.log(f"Storage path: {self.storage_path}", "INFO")
        self.log(f"Config directory: {self.config_dir}", "INFO")

    def load_env(self):
        """Load environment variables from .env files in several common locations."""
        env_locations = [
            Path.cwd() / ".env",
            self.project_root / ".env",
            Path.home() / "Desktop" / "Surge" / ".env"
        ]
        for env_path in env_locations:
            if env_path.exists():
                self.log(f"Loading environment from {env_path}", "INFO")
                with open(env_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith('#') and '=' in line:
                            key, value = line.split('=', 1)
                            os.environ[key] = value
        

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

            # Create CineSync media directories under downloads/CineSync
            media_base = Path(self.storage_path) / "downloads" / "CineSync"


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

            # Debug: print all folder names to be created
            self.log(f"Folders to be created under {media_base}: {standard_dirs}", "INFO")

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
        import time
        try:
            self.log("Delaying CineSync configuration to allow dependencies to start...", "INFO")
            time.sleep(30)  # Wait 30 seconds before starting
            self.log("Loading CineSync configuration template...", "INFO")

            if not self.template_file.exists():
                self.log(f"Template file not found: {self.template_file}", "ERROR")
                return False

            # Load default configuration
            self.config = {
                # Directory Paths
                'SOURCE_DIR': os.environ.get('CINESYNC_SOURCE_DIR', f'{self.storage_path}/downloads/Decypharr/debrids'),
                'DESTINATION_DIR': os.environ.get('CINESYNC_DESTINATION_DIR', f'{self.storage_path}/downloads/CineSync'),
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

            # Validate source directory exists or can be created, with retry
            source_dir = Path(self.config['SOURCE_DIR'])
            max_retries = 5
            for attempt in range(max_retries):
                if source_dir.exists():
                    break
                try:
                    self.log(f"Source directory doesn't exist, creating: {source_dir} (attempt {attempt+1})", "WARNING")
                    source_dir.mkdir(parents=True, exist_ok=True)
                    break
                except PermissionError as e:
                    self.log(f"Permission denied creating source directory: {e}. Retrying in 10 seconds...", "ERROR")
                    time.sleep(10)
                except Exception as e:
                    self.log(f"Error creating source directory: {e}. Retrying in 10 seconds...", "ERROR")
                    time.sleep(10)
            else:
                self.log(f"Failed to create source directory after {max_retries} attempts: {source_dir}", "ERROR")
                return False

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
        """Generate the CineSync environment file with all variables from env.example."""
        try:
            self.log("Generating CineSync environment file...", "INFO")

            # Helper to get config or default
            def get(key, default):
                return str(self.config.get(key, os.environ.get(key, default)))

            env_content = []
            env_content.append("# CineSync Configuration - Auto-generated by Surge")
            env_content.append(f"# Generated on: {time.strftime('%Y-%m-%d %H:%M:%S')}")
            env_content.append("")

            # Directory Paths
            env_content.append("# ========================================")
            env_content.append("# Directory Paths")
            env_content.append("# ========================================")
            env_content.append(f'SOURCE_DIR="{get("SOURCE_DIR","/path/to/files")}"')
            env_content.append(f'DESTINATION_DIR="{get("DESTINATION_DIR","/path/to/destination")}"')
            env_content.append(f"USE_SOURCE_STRUCTURE={get('USE_SOURCE_STRUCTURE','false')}")
            env_content.append("")

            # Media Organization
            env_content.append("# ========================================")
            env_content.append("# Media Organization Configuration")
            env_content.append("# ========================================")
            env_content.append(f"CINESYNC_LAYOUT={get('CINESYNC_LAYOUT','true')}")
            env_content.append(f"ANIME_SEPARATION={get('ANIME_SEPARATION','true')}")
            env_content.append(f"4K_SEPARATION={get('4K_SEPARATION','false')}")
            env_content.append(f"KIDS_SEPARATION={get('KIDS_SEPARATION','false')}")
            env_content.append(f"CUSTOM_SHOW_FOLDER={get('CUSTOM_SHOW_FOLDER','Shows')}")
            env_content.append(f"CUSTOM_4KSHOW_FOLDER={get('CUSTOM_4KSHOW_FOLDER','4KShows')}")
            env_content.append(f"CUSTOM_ANIME_SHOW_FOLDER={get('CUSTOM_ANIME_SHOW_FOLDER','AnimeShows')}")
            env_content.append(f"CUSTOM_MOVIE_FOLDER={get('CUSTOM_MOVIE_FOLDER','Movies')}")
            env_content.append(f"CUSTOM_4KMOVIE_FOLDER={get('CUSTOM_4KMOVIE_FOLDER','4KMovies')}")
            env_content.append(f"CUSTOM_ANIME_MOVIE_FOLDER={get('CUSTOM_ANIME_MOVIE_FOLDER','AnimeMovies')}")
            env_content.append(f"CUSTOM_KIDS_MOVIE_FOLDER={get('CUSTOM_KIDS_MOVIE_FOLDER','KidsMovies')}")
            env_content.append(f"CUSTOM_KIDS_SHOW_FOLDER={get('CUSTOM_KIDS_SHOW_FOLDER','KidsShows')}")
            env_content.append(f"CUSTOM_SPORTS_FOLDER={get('CUSTOM_SPORTS_FOLDER','Sports')}")
            env_content.append("")

            # Resolution-Based Organization
            env_content.append("# ========================================")
            env_content.append("# Resolution-Based Organization")
            env_content.append("# ========================================")
            env_content.append(f"SHOW_RESOLUTION_STRUCTURE={get('SHOW_RESOLUTION_STRUCTURE','false')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_REMUX_4K={get('SHOW_RESOLUTION_FOLDER_REMUX_4K','UltraHDRemuxShows')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_REMUX_1080P={get('SHOW_RESOLUTION_FOLDER_REMUX_1080P','1080pRemuxLibrary')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_REMUX_DEFAULT={get('SHOW_RESOLUTION_FOLDER_REMUX_DEFAULT','RemuxShows')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_2160P={get('SHOW_RESOLUTION_FOLDER_2160P','UltraHD')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_1080P={get('SHOW_RESOLUTION_FOLDER_1080P','FullHD')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_720P={get('SHOW_RESOLUTION_FOLDER_720P','SDClassics')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_480P={get('SHOW_RESOLUTION_FOLDER_480P','Retro480p')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_DVD={get('SHOW_RESOLUTION_FOLDER_DVD','RetroDVD')}")
            env_content.append(f"SHOW_RESOLUTION_FOLDER_DEFAULT={get('SHOW_RESOLUTION_FOLDER_DEFAULT','Shows')}")
            env_content.append(f"MOVIE_RESOLUTION_STRUCTURE={get('MOVIE_RESOLUTION_STRUCTURE','false')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_REMUX_4K={get('MOVIE_RESOLUTION_FOLDER_REMUX_4K','4KRemux')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_REMUX_1080P={get('MOVIE_RESOLUTION_FOLDER_REMUX_1080P','1080pRemux')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_REMUX_DEFAULT={get('MOVIE_RESOLUTION_FOLDER_REMUX_DEFAULT','MoviesRemux')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_2160P={get('MOVIE_RESOLUTION_FOLDER_2160P','UltraHD')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_1080P={get('MOVIE_RESOLUTION_FOLDER_1080P','FullHD')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_720P={get('MOVIE_RESOLUTION_FOLDER_720P','SDMovies')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_480P={get('MOVIE_RESOLUTION_FOLDER_480P','Retro480p')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_DVD={get('MOVIE_RESOLUTION_FOLDER_DVD','DVDClassics')}")
            env_content.append(f"MOVIE_RESOLUTION_FOLDER_DEFAULT={get('MOVIE_RESOLUTION_FOLDER_DEFAULT','Movies')}")
            env_content.append("")

            # Logging
            env_content.append("# ========================================")
            env_content.append("# Logging Configuration")
            env_content.append("# ========================================")
            env_content.append(f"LOG_LEVEL={get('LOG_LEVEL','INFO')}")
            env_content.append("")

            # Rclone Mount
            env_content.append("# ========================================")
            env_content.append("# Rclone Mount Configuration")
            env_content.append("# ========================================")
            env_content.append(f"RCLONE_MOUNT={get('RCLONE_MOUNT','false')}")
            env_content.append(f"MOUNT_CHECK_INTERVAL={get('MOUNT_CHECK_INTERVAL','30')}")
            env_content.append("")

            # TMDb/IMDB
            env_content.append("# ========================================")
            env_content.append("# TMDb/IMDB Configuration")
            env_content.append("# ========================================")
            env_content.append(f"TMDB_API_KEY={get('TMDB_API_KEY','your_tmdb_api_key_here')}")
            env_content.append(f"LANGUAGE={get('LANGUAGE','English')}")
            env_content.append(f"ANIME_SCAN={get('ANIME_SCAN','false')}")
            env_content.append(f"TMDB_FOLDER_ID={get('TMDB_FOLDER_ID','false')}")
            env_content.append(f"IMDB_FOLDER_ID={get('IMDB_FOLDER_ID','false')}")
            env_content.append(f"TVDB_FOLDER_ID={get('TVDB_FOLDER_ID','false')}")
            env_content.append(f"RENAME_ENABLED={get('RENAME_ENABLED','false')}")
            env_content.append(f"MEDIAINFO_PARSER={get('MEDIAINFO_PARSER','false')}")
            env_content.append(f"RENAME_TAGS={get('RENAME_TAGS','Resolution')}")
            env_content.append(f"MEDIAINFO_RADARR_TAGS={get('MEDIAINFO_RADARR_TAGS','{Movie Title} ({Release Year}) {Quality Full}')}")
            env_content.append(f"MEDIAINFO_SONARR_STANDARD_EPISODE_FORMAT={get('MEDIAINFO_SONARR_STANDARD_EPISODE_FORMAT','{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}')}")
            env_content.append(f"MEDIAINFO_SONARR_DAILY_EPISODE_FORMAT={get('MEDIAINFO_SONARR_DAILY_EPISODE_FORMAT','{Series Title} - {Air-Date} - {Episode Title} {Quality Full}')}")
            env_content.append(f"MEDIAINFO_SONARR_ANIME_EPISODE_FORMAT={get('MEDIAINFO_SONARR_ANIME_EPISODE_FORMAT','{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}')}")
            env_content.append(f"MEDIAINFO_SONARR_SEASON_FOLDER_FORMAT={get('MEDIAINFO_SONARR_SEASON_FOLDER_FORMAT','Season{season}')}")
            env_content.append("")

            # Movie Collection
            env_content.append("# ========================================")
            env_content.append("# Movie Collection Settings")
            env_content.append("# ========================================")
            env_content.append(f"MOVIE_COLLECTION_ENABLED={get('MOVIE_COLLECTION_ENABLED','false')}")
            env_content.append("")

            # System
            env_content.append("# ========================================")
            env_content.append("# System based Configuration")
            env_content.append("# ========================================")
            env_content.append(f"RELATIVE_SYMLINK={get('RELATIVE_SYMLINK','false')}")
            env_content.append(f"MAX_CORES={get('MAX_CORES','1')}")
            env_content.append(f"MAX_PROCESSES={get('MAX_PROCESSES','15')}")
            env_content.append("")

            # File Handling
            env_content.append("# ========================================")
            env_content.append("# File Handling Configuration")
            env_content.append("# ========================================")
            env_content.append(f"SKIP_EXTRAS_FOLDER={get('SKIP_EXTRAS_FOLDER','true')}")
            env_content.append(f"SHOW_EXTRAS_SIZE_LIMIT={get('SHOW_EXTRAS_SIZE_LIMIT','5')}")
            env_content.append(f"MOVIE_EXTRAS_SIZE_LIMIT={get('MOVIE_EXTRAS_SIZE_LIMIT','250')}")
            env_content.append(f"ALLOWED_EXTENSIONS={get('ALLOWED_EXTENSIONS','.mp4,.mkv,.srt,.avi,.mov,.divx,.strm')}")
            env_content.append(f"SKIP_ADULT_PATTERNS={get('SKIP_ADULT_PATTERNS','true')}")
            env_content.append("")

            # Real-Time Monitoring
            env_content.append("# ========================================")
            env_content.append("# Real-Time Monitoring Configuration")
            env_content.append("# ========================================")
            env_content.append(f"SLEEP_TIME={get('SLEEP_TIME','60')}")
            env_content.append(f"SYMLINK_CLEANUP_INTERVAL={get('SYMLINK_CLEANUP_INTERVAL','600')}")
            env_content.append("")

            # Plex Integration
            env_content.append("# ========================================")
            env_content.append("# Plex Integration Configuration")
            env_content.append("# ========================================")
            env_content.append(f"ENABLE_PLEX_UPDATE={get('ENABLE_PLEX_UPDATE','false')}")
            env_content.append(f"PLEX_URL={get('PLEX_URL','your-plex-url')}")
            env_content.append(f"PLEX_TOKEN={get('PLEX_TOKEN','your-plex-token')}")
            env_content.append("")

            # CineSync Configuration
            env_content.append("# ========================================")
            env_content.append("# CineSync Configuration")
            env_content.append("# ========================================")
            env_content.append(f"CINESYNC_IP={get('CINESYNC_IP','0.0.0.0')}")
            env_content.append(f"CINESYNC_API_PORT={get('CINESYNC_API_PORT','8082')}")
            env_content.append(f"CINESYNC_UI_PORT={get('CINESYNC_UI_PORT','5173')}")
            env_content.append(f"CINESYNC_AUTH_ENABLED={get('CINESYNC_AUTH_ENABLED','true')}")
            env_content.append(f"CINESYNC_USERNAME={get('CINESYNC_USERNAME','admin')}")
            env_content.append(f"CINESYNC_PASSWORD={get('CINESYNC_PASSWORD','admin')}")
            env_content.append("")

            # MediaHub Service
            env_content.append("# ========================================")
            env_content.append("# MediaHub Service Configuration")
            env_content.append("# ========================================")
            env_content.append(f"MEDIAHUB_AUTO_START={get('MEDIAHUB_AUTO_START','true')}")
            env_content.append(f"RTM_AUTO_START={get('RTM_AUTO_START','false')}")
            env_content.append(f"FILE_OPERATIONS_AUTO_MODE={get('FILE_OPERATIONS_AUTO_MODE','true')}")
            env_content.append("")

            # Database
            env_content.append("# ========================================")
            env_content.append("# Database Configuration")
            env_content.append("# ========================================")
            env_content.append(f"DB_THROTTLE_RATE={get('DB_THROTTLE_RATE','100')}")
            env_content.append(f"DB_MAX_RETRIES={get('DB_MAX_RETRIES','10')}")
            env_content.append(f"DB_RETRY_DELAY={get('DB_RETRY_DELAY','1.0')}")
            env_content.append(f"DB_BATCH_SIZE={get('DB_BATCH_SIZE','1000')}")
            env_content.append(f"DB_MAX_WORKERS={get('DB_MAX_WORKERS','20')}")
            env_content.append("")

            # Docker user settings
            env_content.append(f"PUID={get('PUID','1000')}")
            env_content.append(f"PGID={get('PGID','1000')}")
            env_content.append(f"TZ={get('TZ','UTC')}")

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
