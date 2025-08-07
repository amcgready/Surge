#!/usr/bin/env python3
"""
Kometa Auto-Configuration for Surge

Configures Kometa (formerly Plex Meta Manager) with Plex connection and optimal settings.
"""

import os
import sys
import yaml
from datetime import datetime

class KometaConfigurator:
    def __init__(self, storage_path=None):
        self.storage_path = storage_path or '/opt/surge'
        self.config_dir = f"{self.storage_path}/config/kometa"
        self.config_file = f"{self.config_dir}/config.yml"
        
        # Load environment variables
        self.plex_url = os.environ.get('PLEX_URL', 'http://plex:32400')
        self.plex_token = os.environ.get('PLEX_TOKEN', '')
        self.tmdb_api_key = os.environ.get('TMDB_API_KEY', '')
        
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {"INFO": "ℹ️", "SUCCESS": "✅", "WARNING": "⚠️", "ERROR": "❌"}
        icon = icons.get(level, "ℹ️")
        print(f"[{timestamp}] {icon} {message}")
        sys.stdout.flush()
    
    def configure_kometa(self):
        """Configure Kometa with Plex and metadata sources."""
        self.log("Configuring Kometa connection to Plex...", "INFO")
        
        # Create config directory if it doesn't exist
        os.makedirs(self.config_dir, exist_ok=True)
        os.makedirs(f"{self.config_dir}/assets", exist_ok=True)
        
        # Create comprehensive Kometa configuration
        config = {
            'libraries': {
                'Movies': {
                    'collection_files': [
                        'pmm: basic',
                        'pmm: imdb',
                        'pmm: studio', 
                        'pmm: genre',
                        'pmm: actor',
                        'pmm: director',
                        'pmm: decade',
                        'pmm: year'
                    ],
                    'operations': {
                        'delete_collections_with_less': 2,
                        'delete_unmanaged_collections': False,
                        'mass_genre_update': 'tmdb',
                        'mass_content_rating_update': 'omdb',
                        'mass_audience_rating_update': 'mdb_tomatoes',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'mass_user_rating_update': 'imdb',
                        'mass_poster_update': 'tmdb',
                        'mass_background_update': 'tmdb'
                    }
                },
                'TV Shows': {
                    'collection_files': [
                        'pmm: basic',
                        'pmm: imdb',
                        'pmm: network',
                        'pmm: studio',
                        'pmm: genre'
                    ],
                    'operations': {
                        'delete_collections_with_less': 2,
                        'delete_unmanaged_collections': False,
                        'mass_genre_update': 'tmdb',
                        'mass_content_rating_update': 'omdb',
                        'mass_audience_rating_update': 'mdb_tomatoes',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'mass_user_rating_update': 'imdb',
                        'mass_episode_critic_rating_update': 'imdb',
                        'mass_episode_audience_rating_update': 'tmdb',
                        'mass_poster_update': 'tmdb',
                        'mass_background_update': 'tmdb'
                    }
                }
            },
            'settings': {
                'cache': True,
                'cache_expiry': 60,
                'asset_directory': '/config/assets',
                'asset_folders': True,
                'show_unmanaged': True,
                'show_unconfigured': True,
                'show_filtered': False,
                'show_options': False,
                'show_missing': True,
                'show_missing_assets': True,
                'show_missing_season_assets': False,
                'show_missing_episode_assets': False,
                'download_url_assets': False,
                'create_asset_folders': True,
                'prioritize_assets': True,
                'dimensional_asset_rename': False,
                'delete_below_minimum': False,
                'delete_not_scheduled': False,
                'run_again_delay': 2,
                'missing_only_released': False,
                'only_filter_missing': False,
                'tvdb_language': 'en',
                'item_refresh_delay': 0,
                'playlist_sync_to_user': 'all',
                'verify_ssl': True,
                'check_nightly': False
            },
            'plex': {
                'url': self.plex_url,
                'token': self.plex_token,
                'timeout': 60,
                'clean_bundles': False,
                'empty_trash': False,
                'optimize': False
            }
        }
        
        # Add TMDb configuration if API key is available
        if self.tmdb_api_key:
            config['tmdb'] = {
                'apikey': self.tmdb_api_key,
                'language': 'en',
                'cache_expiry': 60
            }
        else:
            self.log("TMDb API key not found - metadata features will be limited", "WARNING")
        
        # Add scheduling
        config['schedule'] = {
            'daily': {
                'delete_collections': False,
                'missing_only_released': False
            }
        }
        
        # Add run configuration
        config['run_order'] = ['collections', 'operations']
        config['operations_only'] = False
        config['collections_only'] = False
        config['run_start'] = True
        config['run_end'] = True
        config['ignore_schedules'] = False
        config['ignore_ghost'] = False
        config['log_requests'] = False
        
        # Write configuration file
        with open(self.config_file, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)
        
        self.log("✅ Kometa configured successfully", "SUCCESS")
        self.log(f"Plex URL: {self.plex_url}", "INFO")
        self.log(f"Config file: {self.config_file}", "INFO")
        self.log("Restart Kometa to apply changes", "INFO")

def main():
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    configurator = KometaConfigurator(storage_path)
    
    try:
        configurator.configure_kometa()
        return 0
    except Exception as e:
        configurator.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
