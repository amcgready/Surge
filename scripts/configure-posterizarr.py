#!/usr/bin/env python3
"""
Posterizarr Configuration Script for Surge

This script automatically configures Posterizarr with:
- Radarr and Sonarr connections for poster management
- Custom poster asset directory setup
- Automated poster generation and management
- Integration with media library structure
"""

import os
import sys
import yaml
import xml.etree.ElementTree as ET
import requests
import time
from datetime import datetime

class SurgePosterizarrConfigurator:
    def __init__(self, storage_path=None):
        self.storage_path = storage_path or self.find_storage_path()
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.posterizarr_config_dir = f"{self.storage_path}/Posterizarr/config"
        self.posterizarr_assets_dir = f"{self.storage_path}/Posterizarr/assets"
        
        # Load environment variables
        self.load_env()
        
        # Service detection
        self.enabled_services = self.detect_enabled_services()
        
        # API keys storage
        self.api_keys = {}
        
        self.log("Posterizarr Configurator initialized", "INFO")
        self.log(f"Storage path: {self.storage_path}", "INFO")
        self.log(f"Posterizarr config: {self.posterizarr_config_dir}", "INFO")
    
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
        
        # Core services that Posterizarr integrates with
        service_checks = {
            'radarr': True,  # Always needed for movie posters
            'sonarr': True,  # Always needed for TV show posters
            'posterizarr': os.environ.get('ENABLE_POSTERIZARR', 'false').lower() == 'true'
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
        """Discover API keys from Radarr and Sonarr."""
        self.log("Discovering service API keys...", "INFO")
        
        # Service config paths
        config_paths = {
            'radarr': f"{self.storage_path}/Radarr/config/config.xml",
            'sonarr': f"{self.storage_path}/Sonarr/config/config.xml"
        }
        
        # Wait for API keys with retry logic
        max_retries = 6
        retry_delay = 10
        
        for attempt in range(max_retries):
            found_keys = {}
            
            for service, config_path in config_paths.items():
                if service in self.enabled_services:
                    api_key = self.get_api_key_from_xml(config_path)
                    if api_key:
                        found_keys[service] = api_key
            
            if len(found_keys) >= 2:  # Need both Radarr and Sonarr
                self.api_keys.update(found_keys)
                self.log(f"Found API keys on attempt {attempt + 1}", "SUCCESS")
                for service in found_keys:
                    self.log(f"✓ {service.title()} API key discovered", "SUCCESS")
                break
            elif attempt < max_retries - 1:
                missing = [s for s in ['radarr', 'sonarr'] if s not in found_keys]
                self.log(f"Waiting for {', '.join(missing)} API keys... (attempt {attempt + 1}/{max_retries})", "INFO")
                time.sleep(retry_delay)
            else:
                self.log("Could not get required API keys after all retries", "ERROR")
                return False
        
        return True
    
    def wait_for_posterizarr(self, timeout=60):
        """Wait for Posterizarr to be ready."""
        self.log("Waiting for Posterizarr to be ready...", "INFO")
        
        port = os.environ.get('POSTERIZARR_PORT', '5060')
        
        for attempt in range(timeout):
            try:
                response = requests.get(f"http://localhost:{port}", timeout=2)
                if response.status_code < 500:
                    self.log("Posterizarr is ready!", "SUCCESS")
                    return True
            except:
                pass
            
            if attempt % 10 == 0 and attempt > 0:
                self.log(f"Still waiting for Posterizarr... ({attempt}/{timeout})", "INFO")
            
            time.sleep(1)
        
        self.log(f"Posterizarr failed to become ready after {timeout} seconds", "WARNING")
        return False
    
    def create_posterizarr_directories(self):
        """Create Posterizarr configuration and asset directories."""
        self.log("Creating Posterizarr directories...", "INFO")
        
        directories = [
            self.posterizarr_config_dir,
            self.posterizarr_assets_dir,
            f"{self.posterizarr_assets_dir}/movies",
            f"{self.posterizarr_assets_dir}/tv",
            f"{self.posterizarr_assets_dir}/overlays",
            f"{self.storage_path}/Posterizarr/logs",
            f"{self.storage_path}/Posterizarr/movies",
            f"{self.storage_path}/Posterizarr/tv"
        ]
        
        for directory in directories:
            os.makedirs(directory, exist_ok=True)
            self.log(f"Created directory: {directory}", "DEBUG")
        
        self.log("Posterizarr directories created successfully", "SUCCESS")
    
    def generate_posterizarr_config(self):
        """Generate Posterizarr configuration file."""
        self.log("Generating Posterizarr configuration...", "INFO")
        
        config = {
            'general': {
                'log_level': 'info',
                'update_interval': 3600,  # 1 hour
                'concurrent_downloads': 2,
                'enable_ssl': False
            },
            'radarr': {
                'enabled': 'radarr' in self.enabled_services and 'radarr' in self.api_keys,
                'url': 'http://surge-radarr:7878',
                'api_key': self.api_keys.get('radarr', ''),
                'root_folder_path': '/movies',
                'poster_folder': '/assets/movies',
                'create_folders': True,
                'search_missing_posters': True,
                'poster_quality': 'high',
                'poster_format': 'jpg',
                'fanart_enabled': True,
                'fanart_folder': '/assets/movies/fanart'
            },
            'sonarr': {
                'enabled': 'sonarr' in self.enabled_services and 'sonarr' in self.api_keys,
                'url': 'http://surge-sonarr:8989',
                'api_key': self.api_keys.get('sonarr', ''),
                'root_folder_path': '/tv',
                'poster_folder': '/assets/tv',
                'create_folders': True,
                'search_missing_posters': True,
                'poster_quality': 'high',
                'poster_format': 'jpg',
                'fanart_enabled': True,
                'fanart_folder': '/assets/tv/fanart'
            },
            'poster_sources': {
                'tmdb': {
                    'enabled': True,
                    'api_key': os.environ.get('TMDB_API_KEY', ''),
                    'language': 'en',
                    'include_adult': False,
                    'fallback_language': 'en'
                },
                'tvdb': {
                    'enabled': True,
                    'api_key': os.environ.get('TVDB_API_KEY', ''),
                    'language': 'en'
                },
                'fanart_tv': {
                    'enabled': bool(os.environ.get('FANART_TV_API_KEY')),
                    'api_key': os.environ.get('FANART_TV_API_KEY', ''),
                    'include_logos': True,
                    'include_backgrounds': True
                }
            },
            'processing': {
                'resize_posters': True,
                'poster_width': 1000,
                'poster_height': 1500,
                'compression_quality': 85,
                'add_overlays': True,
                'overlay_position': 'bottom-right',
                'backup_original': True,
                'backup_folder': '/assets/backups'
            },
            'notifications': {
                'webhook_url': os.environ.get('DISCORD_WEBHOOK_URL', ''),
                'notify_on_download': True,
                'notify_on_error': True,
                'include_poster_preview': True
            }
        }
        
        # Remove empty API keys to avoid errors
        if not config['poster_sources']['tmdb']['api_key']:
            config['poster_sources']['tmdb']['enabled'] = False
            self.log("TMDB API key not found - TMDB source disabled", "WARNING")
        
        if not config['poster_sources']['tvdb']['api_key']:
            config['poster_sources']['tvdb']['enabled'] = False
            self.log("TVDB API key not found - TVDB source disabled", "WARNING")
        
        config_file = f"{self.posterizarr_config_dir}/config.yaml"
        with open(config_file, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)
        
        self.log(f"Configuration saved to {config_file}", "SUCCESS")
        return config_file
    
    def create_example_overlays(self):
        """Create example overlay templates."""
        self.log("Creating example overlay templates...", "INFO")
        
        overlays_dir = f"{self.posterizarr_assets_dir}/overlays"
        
        # Create a simple text overlay example
        overlay_config = {
            'overlays': {
                '4k_overlay': {
                    'type': 'text',
                    'text': '4K',
                    'position': 'top-right',
                    'font_size': 24,
                    'font_color': '#FFD700',
                    'background_color': '#000000',
                    'padding': 5,
                    'conditions': [
                        {'quality_profile': '4K'},
                        {'resolution': '2160p'}
                    ]
                },
                'quality_overlay': {
                    'type': 'text',
                    'text': 'HD',
                    'position': 'bottom-right', 
                    'font_size': 20,
                    'font_color': '#FFFFFF',
                    'background_color': '#0066CC',
                    'padding': 3,
                    'conditions': [
                        {'quality_profile': 'HD-1080p'}
                    ]
                },
                'watched_overlay': {
                    'type': 'icon',
                    'icon': 'checkmark',
                    'position': 'top-left',
                    'size': 32,
                    'color': '#00FF00',
                    'conditions': [
                        {'watched': True}
                    ]
                }
            }
        }
        
        overlay_file = f"{overlays_dir}/overlays.yaml"
        with open(overlay_file, 'w') as f:
            yaml.dump(overlay_config, f, default_flow_style=False, sort_keys=False)
        
        self.log(f"Example overlays created at {overlay_file}", "SUCCESS")
    
    def test_posterizarr_connections(self):
        """Test Posterizarr connections to Radarr and Sonarr."""
        self.log("Testing Posterizarr service connections...", "INFO")
        
        port = os.environ.get('POSTERIZARR_PORT', '5060')
        
        # Test basic connectivity
        try:
            response = requests.get(f"http://localhost:{port}/health", timeout=10)
            if response.status_code == 200:
                self.log("✓ Posterizarr health check passed", "SUCCESS")
            else:
                self.log(f"✗ Posterizarr health check failed: {response.status_code}", "WARNING")
        except Exception as e:
            self.log(f"✗ Posterizarr health check error: {e}", "WARNING")
        
        # Test API endpoints if available
        try:
            # Try to get status from Posterizarr API
            response = requests.get(f"http://localhost:{port}/api/status", timeout=10)
            if response.status_code == 200:
                status = response.json()
                self.log(f"✓ Posterizarr API status: {status.get('status', 'unknown')}", "SUCCESS")
            else:
                self.log("✓ Posterizarr API not yet available (normal for new installation)", "INFO")
        except:
            self.log("✓ Posterizarr API will be available once container starts", "INFO")
    
    def configure_posterizarr(self):
        """Main Posterizarr configuration function."""
        self.log("Starting Posterizarr configuration...", "INFO")
        
        # Check if Posterizarr is enabled
        if 'posterizarr' not in self.enabled_services:
            self.log("Posterizarr is not enabled - skipping configuration", "WARNING")
            return False
        
        try:
            # Discover API keys first
            if not self.discover_service_api_keys():
                self.log("Cannot proceed without Radarr/Sonarr API keys", "ERROR")
                return False
            
            # Create directories
            self.create_posterizarr_directories()
            
            # Generate configuration
            config_file = self.generate_posterizarr_config()
            
            # Create example overlays
            self.create_example_overlays()
            
            # Wait for service and test connections
            if self.wait_for_posterizarr():
                self.test_posterizarr_connections()
            
            # Success summary
            self.log("=== Posterizarr Configuration Complete ===", "SUCCESS")
            self.log(f"✅ Configuration file: {config_file}", "SUCCESS")
            self.log(f"✅ Assets directory: {self.posterizarr_assets_dir}", "SUCCESS")
            self.log(f"✅ Radarr integration: {'Enabled' if self.api_keys.get('radarr') else 'Disabled'}", "SUCCESS")
            self.log(f"✅ Sonarr integration: {'Enabled' if self.api_keys.get('sonarr') else 'Disabled'}", "SUCCESS")
            self.log(f"✅ Posterizarr web interface: http://localhost:{os.environ.get('POSTERIZARR_PORT', '5060')}", "SUCCESS")
            
            # Configuration tips
            self.log("\n💡 Configuration Tips:", "INFO")
            self.log("   • Add TMDB_API_KEY to .env for better poster sources", "INFO")
            self.log("   • Add TVDB_API_KEY to .env for TV show poster sources", "INFO")
            self.log("   • Add FANART_TV_API_KEY to .env for additional artwork", "INFO")
            self.log("   • Customize overlays in assets/overlays/overlays.yaml", "INFO")
            self.log("   • Check logs in Posterizarr/logs/ for troubleshooting", "INFO")
            
            return True
            
        except Exception as e:
            self.log(f"Posterizarr configuration failed: {e}", "ERROR")
            return False

def main():
    """Main execution function."""
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    configurator = SurgePosterizarrConfigurator(storage_path)
    
    try:
        success = configurator.configure_posterizarr()
        return 0 if success else 1
    except Exception as e:
        configurator.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
