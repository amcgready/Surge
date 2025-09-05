#!/usr/bin/env python3
"""
Homepage Configuration Script for Surge

This script automatically configures Homepage dashboard with:
- Service discovery and widget configuration
- API key integration from existing services
- Custom bookmarks and settings
- Dynamic service enablement based on docker-compose profiles
"""

import os
import sys
import yaml
import xml.etree.ElementTree as ET
from datetime import datetime

class SurgeHomepageConfigurator:
    def __init__(self, storage_path=None):
        self.storage_path = storage_path or self.find_storage_path()
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.homepage_config_dir = f"{self.storage_path}/Homepage/config"
        
        # Load environment variables
        self.load_env()
        
        # Service detection
        self.enabled_services = self.detect_enabled_services()
        
        # API keys storage
        self.api_keys = {}
        
        self.log("Homepage Configurator initialized", "INFO")
        self.log(f"Storage path: {self.storage_path}", "INFO")
        self.log(f"Homepage config: {self.homepage_config_dir}", "INFO")
    
    def find_storage_path(self):
        """Find storage path from environment or common locations."""
        possible_paths = [
            os.environ.get('STORAGE_PATH'),
            '/opt/surge',
            os.path.expanduser('~/surge-data'),
            './data'
        ]
        
        for path in possible_paths:
            if path and os.path.exists(path):
                return path
        
        return '/opt/surge'
    
    def load_env(self):
        """Load environment variables from .env file."""
        env_file = os.path.join(self.project_root, '.env')
        if os.path.exists(env_file):
            with open(env_file, 'r') as f:
                for line in f:
                    if '=' in line and not line.strip().startswith('#'):
                        key, value = line.strip().split('=', 1)
                        os.environ[key] = value
    
    def detect_enabled_services(self):
        """Detect which services are enabled based on environment variables."""
        services = []
        
        # Media server detection
        media_server = os.environ.get('MEDIA_SERVER', 'plex').lower()
        services.append(media_server)
        
        # Core services (always enabled)
        services.extend(['radarr', 'sonarr', 'prowlarr', 'overseerr'])
        
        # Optional services
        service_checks = {
            'bazarr': os.environ.get('ENABLE_BAZARR', 'false').lower() == 'true',
            'tautulli': os.environ.get('ENABLE_TAUTULLI', 'false').lower() == 'true',
            'nzbget': os.environ.get('ENABLE_NZBGET', 'false').lower() == 'true',
            'rdt-client': os.environ.get('ENABLE_RDT_CLIENT', 'false').lower() == 'true',
            'gaps': os.environ.get('ENABLE_GAPS', 'false').lower() == 'true',
            'zurg': os.environ.get('ENABLE_ZURG', 'false').lower() == 'true',
            'cinesync': os.environ.get('ENABLE_CINESYNC', 'false').lower() == 'true',
            'placeholdarr': os.environ.get('ENABLE_PLACEHOLDARR', 'false').lower() == 'true',
            'kometa': os.environ.get('ENABLE_KOMETA', 'false').lower() == 'true',
            'posterizarr': os.environ.get('ENABLE_POSTERIZARR', 'false').lower() == 'true',
            'cli-debrid': os.environ.get('ENABLE_CLI_DEBRID', 'false').lower() == 'true',
            'decypharr': os.environ.get('ENABLE_DECYPHARR', 'false').lower() == 'true'
        }
        
        for service, enabled in service_checks.items():
            if enabled:
                services.append(service)
        
        return services
    
    def log(self, message, level="INFO"):
        """Enhanced logging with timestamps."""
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {
            "INFO": "ℹ️", "SUCCESS": "✅", "WARNING": "⚠️", 
            "ERROR": "❌", "DEBUG": "🔍"
        }
        icon = icons.get(level, "ℹ️")
        print(f"[{timestamp}] {icon} {message}")
        sys.stdout.flush()
    
    def get_api_key_from_xml(self, config_path):
        """Extract API key from XML configuration file."""
        try:
            if not os.path.exists(config_path):
                return None
            
            tree = ET.parse(config_path)
            root = tree.getroot()
            api_key_element = root.find('ApiKey')
            
            if api_key_element is not None and api_key_element.text:
                return api_key_element.text.strip()
        except Exception as e:
            self.log(f"Error reading API key from {config_path}: {e}", "DEBUG")
        
        return None
    
    def discover_service_api_keys(self):
        """Discover API keys from all services."""
        self.log("Discovering service API keys...", "INFO")
        
        # XML-based services
        xml_services = {
            'radarr': f"{self.storage_path}/Radarr/config/config.xml",
            'sonarr': f"{self.storage_path}/Sonarr/config/config.xml",
            'prowlarr': f"{self.storage_path}/Prowlarr/config/config.xml"
        }
        
        for service, config_path in xml_services.items():
            if service in self.enabled_services:
                api_key = self.get_api_key_from_xml(config_path)
                if api_key:
                    self.api_keys[service] = api_key
                    self.log(f"Found {service} API key", "SUCCESS")
        
        # Get Plex token
        plex_token = os.environ.get('PLEX_TOKEN')
        if plex_token and 'plex' in self.enabled_services:
            self.api_keys['plex'] = plex_token
            self.log("Found Plex token", "SUCCESS")
        
        # Get other tokens from environment
        token_mapping = {
            'tautulli': 'TAUTULLI_API_KEY',
            'overseerr': 'OVERSEERR_API_KEY',
            'emby': 'EMBY_TOKEN',
            'jellyfin': 'JELLYFIN_TOKEN'
        }
        
        for service, env_var in token_mapping.items():
            if service in self.enabled_services:
                token = os.environ.get(env_var)
                if token:
                    self.api_keys[service] = token
                    self.log(f"Found {service} token", "SUCCESS")
    
    def create_homepage_directories(self):
        """Create Homepage configuration directories."""
        self.log("Creating Homepage configuration directories...", "INFO")
        
        os.makedirs(self.homepage_config_dir, exist_ok=True)
        
        # Create subdirectories
        subdirs = ['bookmarks', 'widgets', 'services', 'docker']
        for subdir in subdirs:
            os.makedirs(f"{self.homepage_config_dir}/{subdir}", exist_ok=True)
        
        self.log("Homepage directories created", "SUCCESS")
    
    def generate_settings_yaml(self):
        """Generate homepage settings.yaml configuration."""
        self.log("Generating settings.yaml configuration...", "INFO")
        
        settings = {
            'title': 'Surge - Media Management Stack',
            'subtitle': 'Your unified media automation hub',
            'logo': 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/plex.png',
            'header': True,
            'favicon': 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/plex.png',
            'theme': 'dark',
            'color': 'slate',
            'layout': {
                'Media Servers': {
                    'style': 'row',
                    'columns': 3
                },
                'Media Management': {
                    'style': 'row', 
                    'columns': 4
                },
                'Download Clients': {
                    'style': 'row',
                    'columns': 3
                },
                'Monitoring & Tools': {
                    'style': 'row',
                    'columns': 3
                }
            },
            'providers': {
                'openweathermap': os.environ.get('OPENWEATHER_API_KEY', ''),
                'weatherapi': os.environ.get('WEATHER_API_KEY', '')
            } if os.environ.get('OPENWEATHER_API_KEY') or os.environ.get('WEATHER_API_KEY') else {}
        }
        
        settings_file = f"{self.homepage_config_dir}/settings.yaml"
        with open(settings_file, 'w') as f:
            yaml.dump(settings, f, default_flow_style=False, sort_keys=False)
        
        self.log(f"Settings configuration saved to {settings_file}", "SUCCESS")
    
    def generate_services_yaml(self):
        """Generate homepage services.yaml configuration."""
        self.log("Generating services.yaml configuration...", "INFO")
        
        services = {}
        
        # Media Servers
        media_servers = {}
        if 'plex' in self.enabled_services:
            media_servers['Plex'] = {
                'icon': 'plex.png',
                'href': f"http://localhost:{os.environ.get('PLEX_PORT', '32400')}/web",
                'description': 'Stream your media collection',
                'server': 'surge-plex',
                'container': 'surge-plex'
            }
            if 'plex' in self.api_keys:
                media_servers['Plex']['widget'] = {
                    'type': 'plex',
                    'url': 'http://surge-plex:32400',
                    'key': self.api_keys['plex']
                }
        
        if 'emby' in self.enabled_services:
            media_servers['Emby'] = {
                'icon': 'emby.png',
                'href': f"http://localhost:{os.environ.get('EMBY_PORT', '8096')}",
                'description': 'Your personal media server',
                'server': 'surge-emby',
                'container': 'surge-emby'
            }
            if 'emby' in self.api_keys:
                media_servers['Emby']['widget'] = {
                    'type': 'emby',
                    'url': 'http://surge-emby:8096',
                    'key': self.api_keys['emby']
                }
        
        if 'jellyfin' in self.enabled_services:
            media_servers['Jellyfin'] = {
                'icon': 'jellyfin.png', 
                'href': f"http://localhost:{os.environ.get('JELLYFIN_PORT', '8096')}",
                'description': 'Free software media system',
                'server': 'surge-jellyfin',
                'container': 'surge-jellyfin'
            }
            if 'jellyfin' in self.api_keys:
                media_servers['Jellyfin']['widget'] = {
                    'type': 'jellyfin',
                    'url': 'http://surge-jellyfin:8096',
                    'key': self.api_keys['jellyfin']
                }
        
        if media_servers:
            services['Media Servers'] = list(media_servers.values())
        
        # Media Management
        management_services = {}
        
        if 'radarr' in self.enabled_services:
            management_services['Radarr'] = {
                'icon': 'radarr.png',
                'href': f"http://localhost:{os.environ.get('RADARR_PORT', '7878')}",
                'description': 'Movie collection manager',
                'server': 'surge-radarr',
                'container': 'surge-radarr'
            }
            if 'radarr' in self.api_keys:
                management_services['Radarr']['widget'] = {
                    'type': 'radarr',
                    'url': 'http://surge-radarr:7878',
                    'key': self.api_keys['radarr']
                }
        
        if 'sonarr' in self.enabled_services:
            management_services['Sonarr'] = {
                'icon': 'sonarr.png',
                'href': f"http://localhost:{os.environ.get('SONARR_PORT', '8989')}",
                'description': 'TV series manager',
                'server': 'surge-sonarr',
                'container': 'surge-sonarr'
            }
            if 'sonarr' in self.api_keys:
                management_services['Sonarr']['widget'] = {
                    'type': 'sonarr',
                    'url': 'http://surge-sonarr:8989',
                    'key': self.api_keys['sonarr']
                }
        
        if 'prowlarr' in self.enabled_services:
            management_services['Prowlarr'] = {
                'icon': 'prowlarr.png',
                'href': f"http://localhost:{os.environ.get('PROWLARR_PORT', '9696')}",
                'description': 'Indexer manager',
                'server': 'surge-prowlarr', 
                'container': 'surge-prowlarr'
            }
            if 'prowlarr' in self.api_keys:
                management_services['Prowlarr']['widget'] = {
                    'type': 'prowlarr',
                    'url': 'http://surge-prowlarr:9696',
                    'key': self.api_keys['prowlarr']
                }
        
        if 'overseerr' in self.enabled_services:
            management_services['Overseerr'] = {
                'icon': 'overseerr.png',
                'href': f"http://localhost:{os.environ.get('OVERSEERR_PORT', '5055')}",
                'description': 'Request management',
                'server': 'surge-overseerr',
                'container': 'surge-overseerr'
            }
            if 'overseerr' in self.api_keys:
                management_services['Overseerr']['widget'] = {
                    'type': 'overseerr',
                    'url': 'http://surge-overseerr:5055',
                    'key': self.api_keys['overseerr']
                }
        
        if 'bazarr' in self.enabled_services:
            management_services['Bazarr'] = {
                'icon': 'bazarr.png',
                'href': f"http://localhost:{os.environ.get('BAZARR_PORT', '6767')}",
                'description': 'Subtitle management',
                'server': 'surge-bazarr',
                'container': 'surge-bazarr'
            }
        
        if management_services:
            services['Media Management'] = list(management_services.values())
        
        # Download Clients
        download_services = {}
        
        if 'nzbget' in self.enabled_services:
            download_services['NZBGet'] = {
                'icon': 'nzbget.png',
                'href': f"http://localhost:{os.environ.get('NZBGET_PORT', '6789')}",
                'description': 'Usenet downloader',
                'server': 'surge-nzbget',
                'container': 'surge-nzbget'
            }
        
        if 'rdt-client' in self.enabled_services:
            download_services['RDT-Client'] = {
                'icon': 'realdebrid.png',
                'href': f"http://localhost:{os.environ.get('RDT_CLIENT_PORT', '6500')}",
                'description': 'Real-Debrid client',
                'server': 'surge-rdt-client',
                'container': 'surge-rdt-client'
            }
        
        if download_services:
            services['Download Clients'] = list(download_services.values())
        
        # Monitoring & Tools
        monitoring_services = {}
        
        if 'tautulli' in self.enabled_services:
            monitoring_services['Tautulli'] = {
                'icon': 'tautulli.png',
                'href': f"http://localhost:{os.environ.get('TAUTULLI_PORT', '8181')}",
                'description': 'Media server statistics',
                'server': 'surge-tautulli',
                'container': 'surge-tautulli'
            }
            if 'tautulli' in self.api_keys:
                monitoring_services['Tautulli']['widget'] = {
                    'type': 'tautulli',
                    'url': 'http://surge-tautulli:8181',
                    'key': self.api_keys['tautulli']
                }
        
        if 'gaps' in self.enabled_services:
            monitoring_services['GAPS'] = {
                'icon': 'gaps.png',
                'href': f"http://localhost:{os.environ.get('GAPS_PORT', '8484')}",
                'description': 'Collection gap analysis',
                'server': 'surge-gaps',
                'container': 'surge-gaps'
            }
        
        if 'posterizarr' in self.enabled_services:
            monitoring_services['Posterizarr'] = {
                'icon': 'posterizarr.png',
                'href': f"http://localhost:{os.environ.get('POSTERIZARR_PORT', '5060')}",
                'description': 'Custom poster management',
                'server': 'surge-posterizarr',
                'container': 'surge-posterizarr'
            }
        
        if monitoring_services:
            services['Monitoring & Tools'] = list(monitoring_services.values())
        
        services_file = f"{self.homepage_config_dir}/services.yaml"
        with open(services_file, 'w') as f:
            yaml.dump(services, f, default_flow_style=False, sort_keys=False)
        
        self.log(f"Services configuration saved to {services_file}", "SUCCESS")
        return len(services)
    
    def generate_bookmarks_yaml(self):
        """Generate homepage bookmarks.yaml configuration."""
        self.log("Generating bookmarks.yaml configuration...", "INFO")
        
        bookmarks = [
            {
                'Development': [
                    {
                        'name': 'GitHub - Surge',
                        'url': 'https://github.com/amcgready/Surge',
                        'icon': 'github.png'
                    },
                    {
                        'name': 'Docker Hub',
                        'url': 'https://hub.docker.com/',
                        'icon': 'docker.png'
                    }
                ]
            },
            {
                'Media': [
                    {
                        'name': 'TMDB',
                        'url': 'https://www.themoviedb.org/',
                        'icon': 'tmdb.png'
                    },
                    {
                        'name': 'TVDB',
                        'url': 'https://thetvdb.com/',
                        'icon': 'tvdb.png'
                    },
                    {
                        'name': 'IMDB',
                        'url': 'https://www.imdb.com/',
                        'icon': 'imdb.png'
                    }
                ]
            }
        ]
        
        # Add Real-Debrid bookmark if RDT services are enabled
        if any(service in self.enabled_services for service in ['rdt-client', 'zurg', 'cli-debrid']):
            bookmarks.append({
                'Debrid Services': [
                    {
                        'name': 'Real-Debrid',
                        'url': 'https://real-debrid.com/',
                        'icon': 'realdebrid.png'
                    }
                ]
            })
        
        bookmarks_file = f"{self.homepage_config_dir}/bookmarks.yaml"
        with open(bookmarks_file, 'w') as f:
            yaml.dump(bookmarks, f, default_flow_style=False, sort_keys=False)
        
        self.log(f"Bookmarks configuration saved to {bookmarks_file}", "SUCCESS")
    
    def generate_docker_yaml(self):
        """Generate homepage docker.yaml configuration."""
        self.log("Generating docker.yaml configuration...", "INFO")
        
        docker_config = {
            'my-docker': {
                'socket': '/var/run/docker.sock'
            }
        }
        
        docker_file = f"{self.homepage_config_dir}/docker.yaml"
        with open(docker_file, 'w') as f:
            yaml.dump(docker_config, f, default_flow_style=False, sort_keys=False)
        
        self.log(f"Docker configuration saved to {docker_file}", "SUCCESS")
    
    def configure_homepage(self):
        """Main homepage configuration function."""
        self.log("Starting Homepage configuration...", "INFO")
        
        try:
            # Create directories
            self.create_homepage_directories()
            
            # Discover API keys
            self.discover_service_api_keys()
            
            # Generate configuration files
            self.generate_settings_yaml()
            service_count = self.generate_services_yaml()
            self.generate_bookmarks_yaml()
            self.generate_docker_yaml()
            
            # Summary
            self.log("=== Homepage Configuration Complete ===", "SUCCESS")
            self.log(f"✅ Configured {service_count} service groups", "SUCCESS")
            self.log(f"✅ Found {len(self.api_keys)} API keys/tokens", "SUCCESS")
            self.log(f"✅ Homepage available at: http://localhost:{os.environ.get('HOMEPAGE_PORT', '3004')}", "SUCCESS")
            self.log("✅ All configuration files generated successfully", "SUCCESS")
            
            return True
            
        except Exception as e:
            self.log(f"Homepage configuration failed: {e}", "ERROR")
            return False

def main():
    """Main execution function."""
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    configurator = SurgeHomepageConfigurator(storage_path)
    
    try:
        success = configurator.configure_homepage()
        return 0 if success else 1
    except Exception as e:
        configurator.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
