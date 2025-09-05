#!/usr/bin/env python3
"""
Kometa Auto-Configuration for Surge

Configures Kometa (formerly Plex Meta Manager) with Plex connection and optimal settings.
"""

import os
import sys
import yaml
import subprocess
from datetime import datetime
from pathlib import Path

class KometaConfigurator:
    def __init__(self, storage_path=None):
        # Explicitly load and export variables from the main .env in the project folder
        self.project_env_path = Path.home() / "Desktop" / "Surge" / ".env"
        if self.project_env_path.exists():
            with open(self.project_env_path, 'r') as f:
                for line in f:
                    if line.strip() and not line.strip().startswith('#') and '=' in line:
                        key, value = line.strip().split('=', 1)
                        os.environ[key] = value
        self.storage_path = storage_path
        self.kometa_repo = "https://github.com/Kometa-Team/Kometa.git"
        # Load environment variables
        self.plex_url = 'http://localhost:32400'
        self.plex_token = os.environ.get('PLEX_TOKEN', '')
        self.tmdb_api_key = os.environ.get('TMDB_API_KEY', '')
        self.discord_webhook = os.environ.get('DISCORD_WEBHOOK_URL', '')
        
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {"INFO": "ℹ️", "SUCCESS": "✅", "WARNING": "⚠️", "ERROR": "❌"}
        icon = icons.get(level, "ℹ️")
        print(f"[{timestamp}] {icon} {message}")
        sys.stdout.flush()
    

    def configure_kometa(self):
    # Kometa repo should already be cloned by deploy.sh
        self.config_dir = f"{self.storage_path}/Kometa/config"
        self.config_file = f"{self.config_dir}/config.yml"
        self.log("Configuring Kometa connection to Plex...", "INFO")
        # Now create config directory and assets folder
        os.makedirs(self.config_dir, exist_ok=True)
        os.makedirs(f"{self.config_dir}/assets", exist_ok=True)
        # Now create Streaming.yml
        streaming_path = os.path.join(self.config_dir, 'Streaming.yml')
        streaming_content = {
            'collections': {
                'Netflix Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/ryalism/netflix-movies',
                    'url_poster': 'https://theposterdb.com/api/assets/163448',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
                'Disney+ Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/ryalism/disney-movies',
                    'url_poster': 'https://theposterdb.com/api/assets/163294',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
                'AppleTV+ Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/buzzie/appletv-plus',
                    'url_poster': 'https://theposterdb.com/api/assets/163303',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
                'HBO MAX Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/ryalism/hbo-max-movies',
                    'url_poster': 'https://theposterdb.com/api/assets/163885',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
                'Paramount+ Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/buzzie/paramount-plus',
                    'url_poster': 'https://theposterdb.com/api/assets/163819',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
                'Peacock Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/buzzie/peacock',
                    'url_poster': 'https://theposterdb.com/api/assets/163874',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
                'Amazon Movies': {
                    'mdblist_list': 'https://mdblist.com/lists/ryalism/amazon-movies',
                    'url_poster': 'https://theposterdb.com/api/assets/163301',
                    'sort_title': '+01_10_<<collection_name>>',
                    'collection_order': 'custom',
                    'collection_mode': 'hide',
                    'sync_mode': 'sync',
                    'schedule': ['hourly(02)']
                },
            }
        }
        with open(streaming_path, 'w') as f:
            yaml.dump(streaming_content, f, default_flow_style=False, sort_keys=False)
        self.log(f"Streaming.yml written to {streaming_path}", "SUCCESS")
        # Remove any existing config.yml before generating new one
        if os.path.exists(self.config_file):
            try:
                os.remove(self.config_file)
                self.log("Removed existing config.yml before generating new one.", "INFO")
            except Exception as e:
                self.log(f"Failed to remove existing config.yml: {e}", "WARNING")
        # Now create criterion.yml
        criterion_path = os.path.join(self.config_dir, 'criterion.yml')
        criterion_content = {
            'collections': {
                'Criterion Collection': {
                    'trakt_list': 'https://trakt.tv/lists/27683848',
                    'collection_order': 'custom',
                    'sync_mode': 'sync',
                    'url_poster': 'https://theposterdb.com/api/assets/17633/'
                }
            }
        }
        with open(criterion_path, 'w') as f:
            yaml.dump(criterion_content, f, default_flow_style=False, sort_keys=False)
        self.log(f"criterion.yml written to {criterion_path}", "SUCCESS")
        

        # Build config dictionary exactly matching the provided example
        storage_path = self.storage_path
        config = {
            'libraries': {
                'Movies': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'streaming', 'template_variables': {'exclude': ['all4', 'bet', 'britbox', 'crave', 'crunchyroll', 'hayu', 'now'], 'sep_style': 'rust'}},
                        {'default': 'separator_chart', 'template_variables': {'sep_style': 'aqua'}},
                        {'default': 'basic'},
                        {'default': 'imdb', 'template_variables': {'exclude': ['lowest']}},
                        {'default': 'trakt', 'template_variables': {'exclude': ['collected', 'watched']}},
                        {'default': 'separator_award', 'template_variables': {'sep_style': 'sand'}},
                        {'default': 'choice', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'emmy', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'golden', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'pca', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'sundance', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'file': 'config/criterion.yml'},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                        {'default': 'decade', 'template_variables': {'sep_style': 'ocean'}},
                        {'default': 'based', 'template_variables': {'sep_style': 'plum'}},
                        {'default': 'studio', 'template_variables': {'include': ['A24', 'Aardman', 'Blumhouse Productions', 'DreamWorks Studios', 'Hallmark', 'Happy Madison Productions', 'Illumination Entertainment', 'Laika Entertainment', 'Metro-Goldwyn-Mayer', 'Paramount Pictures', 'Pixar', 'Rankin Bass Productions', 'Universal Pictures', 'Walt Disney Pictures', 'Warner Bros. Pictures'], 'sep_style': 'salmon'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                    ],
                    'overlay_files': [
                        {'default': 'ribbon', 'template_variables': {'style': 'yellow', 'use_all': False, 'use_imdb': True, 'use_oscars': True, 'use_sundance': True}},
                        {'default': 'mediastinger', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'right'}},
                        {'default': 'resolution', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'left'}},
                        {'default': 'audio_codec', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'center'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'mass_genre_update': ['imdb'],
                        'mass_content_rating_update': ['mdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['omdb', 'tmdb'],
                        'assets_for_all': True,
                    },
                },
                'Anime Movies': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'basic'},
                        {'default': 'anilist'},
                        {'default': 'myanimelist'},
                        {'file': 'config/criterion.yml'},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                        {'default': 'decade', 'template_variables': {'sep_style': 'ocean'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                    ],
                    'overlay_files': [
                        {'default': 'mediastinger', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'right'}},
                        {'default': 'resolution', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'left'}},
                        {'default': 'audio_codec', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'center'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'mass_genre_update': ['imdb'],
                        'mass_content_rating_update': ['mdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['omdb', 'tmdb'],
                        'assets_for_all': True,
                    },
                },
                'Anime Series': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'streaming', 'template_variables': {'exclude': ['all4', 'bet', 'britbox', 'crave', 'hayu', 'now'], 'sep_style': 'rust'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                        {'default': 'separator_chart', 'template_variables': {'sep_style': 'aqua'}},
                        {'default': 'basic'},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                    ],
                    'overlay_files': [
                        {'default': 'ribbon', 'template_variables': {'style': 'yellow', 'use_all': False, 'use_imdb': True}},
                        {'default': 'resolution', 'template_variables': {'horizontal_align': 'left', 'vertical_align': 'top'}},
                        {'default': 'audio_codec', 'template_variables': {'horizontal_align': 'center', 'vertical_align': 'top'}},
                        {'default': 'status', 'template_variables': {'horizontal_align': 'right', 'vertical_align': 'top'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'assets_for_all': True,
                        'mass_genre_update': ['imdb', 'tvdb', 'anidb'],
                        'mass_content_rating_update': ['omdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['tvdb'],
                    },
                },
                'TV Series': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'streaming', 'template_variables': {'exclude': ['all4', 'bet', 'britbox', 'crave', 'crunchyroll', 'hayu', 'now'], 'sep_style': 'rust'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                        {'default': 'separator_chart', 'template_variables': {'sep_style': 'aqua'}},
                        {'default': 'basic'},
                        {'default': 'imdb', 'template_variables': {'exclude': ['lowest']}},
                        {'default': 'separator_award', 'template_variables': {'sep_style': 'sand'}},
                        {'default': 'emmy', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'golden', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'pca', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                        {'default': 'studio', 'template_variables': {'include': ['A24'], 'sep_style': 'salmon'}},
                        {'default': 'based', 'template_variables': {'sep_style': 'plum'}},
                        {'file': 'config/criterion.yml'},
                    ],
                    'overlay_files': [
                        {'default': 'ribbon', 'template_variables': {'style': 'yellow', 'use_all': False, 'use_imdb': True}},
                        {'default': 'resolution', 'template_variables': {'horizontal_align': 'left', 'vertical_align': 'top'}},
                        {'default': 'audio_codec', 'template_variables': {'horizontal_align': 'center', 'vertical_align': 'top'}},
                        {'default': 'status', 'template_variables': {'horizontal_align': 'right', 'vertical_align': 'top'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'assets_for_all': True,
                        'mass_genre_update': ['imdb', 'tvdb', 'anidb'],
                        'mass_content_rating_update': ['omdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['tvdb'],
                    },
                },
            },
            'playlist_files': [{'default': 'playlist'}],
            'webhooks': {
                'error': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'run_start': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'run_end': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'changes': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'delete': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'version': None,
            },
            'plex': {
                'url': self.plex_url,
                'token': os.environ.get('PLEX_TOKEN', self.plex_token),
                'clean_bundles': False,
                'empty_trash': False,
                'optimize': False,
                'verify_ssl': True,
                'timeout': 1000,
                'db_cache': 100000,
            },
            'tmdb': {
                'apikey': os.environ.get('TMDB_API_KEY', self.tmdb_api_key),
                'language': 'en',
                'cache_expiration': 60,
                'region': 'US',
            },
            'anidb': {
                'client': 'kometarun',
                'version': 1,
                'language': 'en',
                'cache_expiration': 60,
                'username': os.environ.get('ANIDB_USERNAME', ''),
                'password': os.environ.get('ANIDB_PASSWORD', ''),
            },
            'github': {
                'token': os.environ.get('GITHUB_TOKEN', ''),
            },
            'omdb': {
                'apikey': os.environ.get('OMDB_API_KEY', ''),
                'cache_expiration': 60,
            },
            'mdblist': {
                'apikey': os.environ.get('MDBLIST_API_KEY', ''),
                'cache_expiration': 60,
            },
            'radarr': {
                'url': os.environ.get('RADARR_URL', ''),
                'token': os.environ.get('RADARR_TOKEN', ''),
                'add_missing': False,
                'add_existing': False,
                'root_folder_path': f'{storage_path}/downloads/CineSync/Movies',
                'monitor_existing': False,
                'monitor': True,
                'availability': 'announced',
                'quality_profile': 'Ultra-HD',
                'search': True,
                'plex_path': f'{storage_path}/Plex',
                'upgrade_existing': True,
                'ignore_cache': False,
                'tag': None,
                'radarr_path': None,
            },
            'trakt': {
                'client_id': os.environ.get('TRAKT_CLIENT_ID', ''),
                'client_secret': os.environ.get('TRAKT_CLIENT_SECRET', ''),
                'pin': None,
                'authorization': {
                    'access_token': os.environ.get('TRAKT_ACCESS_TOKEN', ''),
                    'token_type': 'Bearer',
                    'expires_in': 7889237,
                    'refresh_token': os.environ.get('TRAKT_REFRESH_TOKEN', ''),
                    'scope': 'public',
                    'created_at': 1751803228,
                },
            },
            'settings': {
                'run_order': ['operations', 'metadata', 'collections', 'overlays'],
                'cache': True,
                'cache_expiration': 60,
                'asset_directory': f'{storage_path}/Assets',
                'asset_folders': True,
                'asset_depth': 1,
                'create_asset_folders': True,
                'prioritize_assets': True,
                'dimensional_asset_rename': False,
                'download_url_assets': False,
                'show_missing_assets': True,
                'show_missing_season_assets': True,
                'show_missing_episode_assets': True,
                'show_asset_not_needed': True,
                'sync_mode': 'append',
                'default_collection_order': None,
                'minimum_items': 1,
                'item_refresh_delay': 0,
                'delete_below_minimum': False,
                'delete_not_scheduled': False,
                'run_again_delay': 0,
                'missing_only_released': False,
                'only_filter_missing': False,
                'show_unmanaged': True,
                'show_unconfigured': True,
                'show_filtered': False,
                'show_options': False,
                'show_missing': True,
                'save_report': False,
                'tvdb_language': 'eng',
                'ignore_ids': None,
                'ignore_imdb_ids': None,
                'playlist_sync_to_users': 'all',
                'playlist_exclude_users': None,
                'playlist_report': True,
                'verify_ssl': True,
                'custom_repo': None,
                'overlay_artwork_filetype': 'jpg',
                'overlay_artwork_quality': 95,
                'show_unfiltered': False,
            },
        }
        storage_path = self.storage_path
        config = {
            'libraries': {
                'Movies': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'streaming', 'template_variables': {'exclude': ['all4', 'bet', 'britbox', 'crave', 'crunchyroll', 'hayu', 'now'], 'sep_style': 'rust'}},
                        {'default': 'separator_chart', 'template_variables': {'sep_style': 'aqua'}},
                        {'default': 'basic'},
                        {'default': 'imdb', 'template_variables': {'exclude': ['lowest']}},
                        {'default': 'trakt', 'template_variables': {'exclude': ['collected', 'watched']}},
                        {'default': 'separator_award', 'template_variables': {'sep_style': 'sand'}},
                        {'default': 'choice', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'emmy', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'golden', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'pca', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'sundance', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'file': 'config/criterion.yml'},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                        {'default': 'decade', 'template_variables': {'sep_style': 'ocean'}},
                        {'default': 'based', 'template_variables': {'sep_style': 'plum'}},
                        {'default': 'studio', 'template_variables': {'include': ['A24', 'Aardman', 'Blumhouse Productions', 'DreamWorks Studios', 'Hallmark', 'Happy Madison Productions', 'Illumination Entertainment', 'Laika Entertainment', 'Metro-Goldwyn-Mayer', 'Paramount Pictures', 'Pixar', 'Rankin Bass Productions', 'Universal Pictures', 'Walt Disney Pictures', 'Warner Bros. Pictures'], 'sep_style': 'salmon'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                    ],
                    'overlay_files': [
                        {'default': 'ribbon', 'template_variables': {'style': 'yellow', 'use_all': False, 'use_imdb': True, 'use_oscars': True, 'use_sundance': True}},
                        {'default': 'mediastinger', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'right'}},
                        {'default': 'resolution', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'left'}},
                        {'default': 'audio_codec', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'center'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'mass_genre_update': ['imdb'],
                        'mass_content_rating_update': ['mdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['omdb', 'tmdb'],
                        'assets_for_all': True,
                    },
                },
                'Anime Movies': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'basic'},
                        {'default': 'anilist'},
                        {'default': 'myanimelist'},
                        {'file': 'config/criterion.yml'},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                        {'default': 'decade', 'template_variables': {'sep_style': 'ocean'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                    ],
                    'overlay_files': [
                        {'default': 'mediastinger', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'right'}},
                        {'default': 'resolution', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'left'}},
                        {'default': 'audio_codec', 'template_variables': {'vertical_align': 'top', 'horizontal_align': 'center'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'mass_genre_update': ['imdb'],
                        'mass_content_rating_update': ['mdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['omdb', 'tmdb'],
                        'assets_for_all': True,
                    },
                },
                'Anime Series': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'streaming', 'template_variables': {'exclude': ['all4', 'bet', 'britbox', 'crave', 'hayu', 'now'], 'sep_style': 'rust'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                        {'default': 'separator_chart', 'template_variables': {'sep_style': 'aqua'}},
                        {'default': 'basic'},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                    ],
                    'overlay_files': [
                        {'default': 'ribbon', 'template_variables': {'style': 'yellow', 'use_all': False, 'use_imdb': True}},
                        {'default': 'resolution', 'template_variables': {'horizontal_align': 'left', 'vertical_align': 'top'}},
                        {'default': 'audio_codec', 'template_variables': {'horizontal_align': 'center', 'vertical_align': 'top'}},
                        {'default': 'status', 'template_variables': {'horizontal_align': 'right', 'vertical_align': 'top'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'assets_for_all': True,
                        'mass_genre_update': ['imdb', 'tvdb', 'anidb'],
                        'mass_content_rating_update': ['omdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['tvdb'],
                    },
                },
                'TV Series': {
                    'reapply_overlays': True,
                    'collection_files': [
                        {'default': 'streaming', 'template_variables': {'exclude': ['all4', 'bet', 'britbox', 'crave', 'crunchyroll', 'hayu', 'now'], 'sep_style': 'rust'}},
                        {'default': 'franchise', 'template_variables': {'sep_style': 'forest'}},
                        {'default': 'universe', 'template_variables': {'sep_style': 'tan'}},
                        {'default': 'separator_chart', 'template_variables': {'sep_style': 'aqua'}},
                        {'default': 'basic'},
                        {'default': 'imdb', 'template_variables': {'exclude': ['lowest']}},
                        {'default': 'separator_award', 'template_variables': {'sep_style': 'sand'}},
                        {'default': 'emmy', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'golden', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'pca', 'template_variables': {'exclude': ['2020', '2021', '2022', '2023']}},
                        {'default': 'genre', 'template_variables': {'sep_style': 'orchid'}},
                        {'default': 'studio', 'template_variables': {'include': ['A24'], 'sep_style': 'salmon'}},
                        {'default': 'based', 'template_variables': {'sep_style': 'plum'}},
                        {'file': 'config/criterion.yml'},
                    ],
                    'overlay_files': [
                        {'default': 'ribbon', 'template_variables': {'style': 'yellow', 'use_all': False, 'use_imdb': True}},
                        {'default': 'resolution', 'template_variables': {'horizontal_align': 'left', 'vertical_align': 'top'}},
                        {'default': 'audio_codec', 'template_variables': {'horizontal_align': 'center', 'vertical_align': 'top'}},
                        {'default': 'status', 'template_variables': {'horizontal_align': 'right', 'vertical_align': 'top'}},
                        {'default': 'ratings', 'template_variables': {'rating1': 'critic', 'rating1_image': 'rt_tomato', 'rating2': 'audience', 'rating2_image': 'rt_popcorn', 'horizontal_position': 'left', 'vertical_position': 'bottom', 'rating_alignment': 'horizontal', 'font_size': 93}},
                    ],
                    'operations': {
                        'mass_audience_rating_update': 'mdb_tomatoesaudience',
                        'mass_critic_rating_update': 'mdb_tomatoes',
                        'assets_for_all': True,
                        'mass_genre_update': ['imdb', 'tvdb', 'anidb'],
                        'mass_content_rating_update': ['omdb'],
                        'mass_studio_update': ['tmdb'],
                        'mass_originally_available_update': ['tvdb'],
                    },
                },
            },
            'playlist_files': [{'default': 'playlist'}],
            'webhooks': {
                'error': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'run_start': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'run_end': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'changes': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'delete': os.environ.get('DISCORD_WEBHOOK_URL', self.discord_webhook),
                'version': None,
            },
            'plex': {
                'url': self.plex_url,
                'token': os.environ.get('PLEX_TOKEN', self.plex_token),
                'clean_bundles': False,
                'empty_trash': False,
                'optimize': False,
                'verify_ssl': True,
                'timeout': 1000,
                'db_cache': 100000,
            },
            'tmdb': {
                'apikey': os.environ.get('TMDB_API_KEY', self.tmdb_api_key),
                'language': 'en',
                'cache_expiration': 60,
                'region': 'US',
            },
            'anidb': {
                'client': 'kometarun',
                'version': 1,
                'language': 'en',
                'cache_expiration': 60,
                'username': os.environ.get('ANIDB_USERNAME', ''),
                'password': os.environ.get('ANIDB_PASSWORD', ''),
            },
            'github': {
                'token': os.environ.get('GITHUB_TOKEN', ''),
            },
            'omdb': {
                'apikey': os.environ.get('OMDB_API_KEY', ''),
                'cache_expiration': 60,
            },
            'mdblist': {
                'apikey': os.environ.get('MDBLIST_API_KEY', ''),
                'cache_expiration': 60,
            },
            'radarr': {
                'url': os.environ.get('RADARR_URL', 'http://192.168.0.22:7878'),
                'token': os.environ.get('RADARR_TOKEN', ''),
                'add_missing': False,
                'add_existing': False,
                'root_folder_path': f'{storage_path}/downloads/CineSync/Movies',
                'monitor_existing': False,
                'monitor': True,
                'availability': 'announced',
                'quality_profile': 'Ultra-HD',
                'search': True,
                'plex_path': f'{storage_path}/Plex',
                'upgrade_existing': True,
                'ignore_cache': False,
                'tag': None,
                'radarr_path': None,
            },
            'trakt': {
                'client_id': os.environ.get('TRAKT_CLIENT_ID', ''),
                'client_secret': os.environ.get('TRAKT_CLIENT_SECRET', ''),
                'pin': None,
                'authorization': {
                    'access_token': os.environ.get('TRAKT_ACCESS_TOKEN', ''),
                    'token_type': 'Bearer',
                    'expires_in': 7889237,
                    'refresh_token': os.environ.get('TRAKT_REFRESH_TOKEN', ''),
                    'scope': 'public',
                    'created_at': 1751803228,
                },
            },
            'settings': {
                'run_order': ['operations', 'metadata', 'collections', 'overlays'],
                'cache': True,
                'cache_expiration': 60,
                'asset_directory': f'{storage_path}/Assets',
                'asset_folders': True,
                'asset_depth': 1,
                'create_asset_folders': True,
                'prioritize_assets': True,
                'dimensional_asset_rename': False,
                'download_url_assets': False,
                'show_missing_assets': True,
                'show_missing_season_assets': True,
                'show_missing_episode_assets': True,
                'show_asset_not_needed': True,
                'sync_mode': 'append',
                'default_collection_order': None,
                'minimum_items': 1,
                'item_refresh_delay': 0,
                'delete_below_minimum': False,
                'delete_not_scheduled': False,
                'run_again_delay': 0,
                'missing_only_released': False,
                'only_filter_missing': False,
                'show_unmanaged': True,
                'show_unconfigured': True,
                'show_filtered': False,
                'show_options': False,
                'show_missing': True,
                'save_report': False,
                'tvdb_language': 'eng',
                'ignore_ids': None,
                'ignore_imdb_ids': None,
                'playlist_sync_to_users': 'all',
                'playlist_exclude_users': None,
                'playlist_report': True,
                'verify_ssl': True,
                'custom_repo': None,
                'overlay_artwork_filetype': 'jpg',
                'overlay_artwork_quality': 95,
                'show_unfiltered': False,
            },
        }
        # Write config file with correct formatting
        with open(self.config_file, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)
        self.log("✅ Kometa config generated with full example structure and env API keys", "SUCCESS")
        self.log(f"Config file: {self.config_file}", "INFO")
        # Write criterion.yml in the config directory
        criterion_path = os.path.join(self.config_dir, 'criterion.yml')
        criterion_content = {
            'collections': {
                'Criterion Collection': {
                    'trakt_list': 'https://trakt.tv/lists/27683848',
                    'collection_order': 'custom',
                    'sync_mode': 'sync',
                    'url_poster': 'https://theposterdb.com/api/assets/17633/'
                }
            }
        }
        with open(criterion_path, 'w') as f:
            yaml.dump(criterion_content, f, default_flow_style=False, sort_keys=False)
        self.log(f"criterion.yml written to {criterion_path}", "SUCCESS")
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
