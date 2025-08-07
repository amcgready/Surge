#!/usr/bin/env python3
"""
Placeholdarr Configuration Script for Surge

Automatically configures Placeholdarr placeholder file management service including:
- Configuration file generation with API integrations
- Connection to Radarr and Sonarr for queue monitoring
- Plex integration for library management
- Placeholder file strategy optimization
- Directory structure validation
- Webhook notifications setup
- Queue monitoring configuration
"""

import os
import sys
import time
import yaml
import xml.etree.ElementTree as ET
import subprocess
from pathlib import Path
from typing import List, Optional

class SurgePlaceholdarrConfigurator:
    def __init__(self, storage_path: Optional[str] = None):
        """Initialize Placeholdarr configurator."""
        self.storage_path = storage_path or self.find_storage_path()
        self.project_root = Path(__file__).parent.parent
        
        # Load environment variables
        self.load_env()
        
        # Configuration paths
        self.config_dir = Path(self.storage_path) / "Placeholdarr" / "config"
        self.config_file = self.config_dir / "config.yml"
        
        # Service detection
        self.enabled_services = self.detect_enabled_services()
        
        # API keys storage
        self.api_keys = {}
        self.config = {}
        
        self.log("Placeholdarr Configurator initialized", "INFO")
        self.log(f"Storage path: {self.storage_path}", "INFO")
        self.log(f"Config file: {self.config_file}", "INFO")

    def find_storage_path(self) -> str:
        """Find the storage path from environment or use default."""
        storage_path = os.environ.get('STORAGE_PATH')
        if not storage_path:
            # Try common locations
            for path in ['/opt/surge', './data', '/data']:
                if os.path.exists(path):
                    return path
            # Default fallback
            return '/opt/surge'
        return storage_path

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
            'ENABLE_PLACEHOLDARR': 'placeholdarr',
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
        """Create necessary directories for Placeholdarr."""
        try:
            self.log("Creating Placeholdarr directory structure...", "INFO")
            
            # Create config directory
            self.config_dir.mkdir(parents=True, exist_ok=True)
            
            # Create placeholder directories
            placeholder_dirs = [
                Path(self.storage_path) / "media" / "placeholders",
                Path(self.storage_path) / "downloads" / "placeholders"
            ]
            
            for dir_path in placeholder_dirs:
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

    def discover_service_api_keys(self) -> bool:
        """Discover API keys from Radarr, Sonarr, and other services."""
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
            
            if found_keys:  # Found at least one API key
                self.api_keys.update(found_keys)
                self.log(f"Found API keys on attempt {attempt + 1}", "SUCCESS")
                for service in found_keys:
                    self.log(f"✓ {service.title()} API key discovered", "SUCCESS")
                break
            elif attempt < max_retries - 1:
                missing = [s for s in ['radarr', 'sonarr'] if s in self.enabled_services and s not in found_keys]
                if missing:
                    self.log(f"Waiting for {', '.join(missing)} API keys... (attempt {attempt + 1}/{max_retries})", "INFO")
                    time.sleep(retry_delay)
            else:
                self.log("Could not get API keys after all retries", "WARNING")
        
        # Get Plex token from environment
        plex_token = os.environ.get('PLEX_TOKEN')
        if plex_token and 'plex' in self.enabled_services:
            self.api_keys['plex'] = plex_token
            self.log("Found Plex token", "SUCCESS")
        
        return len(self.api_keys) > 0

    def get_api_key_from_xml(self, config_path: str) -> Optional[str]:
        """Extract API key from XML configuration file."""
        try:
            if not os.path.exists(config_path):
                return None
            
            tree = ET.parse(config_path)
            root = tree.getroot()
            
            api_key_element = root.find('.//ApiKey')
            if api_key_element is not None and api_key_element.text:
                return api_key_element.text.strip()
            
            return None
            
        except ET.ParseError:
            return None
        except Exception:
            return None

    def load_configuration_settings(self) -> bool:
        """Load Placeholdarr configuration settings."""
        try:
            self.log("Loading Placeholdarr configuration settings...", "INFO")
            
            # Base configuration
            self.config = {
                'general': {
                    'log_level': os.environ.get('PLACEHOLDARR_LOG_LEVEL', 'INFO'),
                    'check_interval': int(os.environ.get('PLACEHOLDARR_CHECK_INTERVAL', '30')),
                    'cleanup_interval': int(os.environ.get('PLACEHOLDARR_CLEANUP_INTERVAL', '1440')),  # 24 hours
                },
                'placeholders': {
                    'strategy': os.environ.get('PLACEHOLDARR_PLACEHOLDER_STRATEGY', 'hardlink'),
                    'file_path': os.environ.get('PLACEHOLDARR_DUMMY_FILE_PATH', f'{self.storage_path}/media/placeholders/dummy.mp4'),
                    'coming_soon_file_path': os.environ.get('PLACEHOLDARR_COMING_SOON_FILE_PATH', f'{self.storage_path}/media/placeholders/coming_soon.mkv'),
                    'min_file_size': int(os.environ.get('PLACEHOLDARR_MIN_FILE_SIZE', '1048576')),  # 1MB
                },
                'webhooks': {
                    'enabled': os.environ.get('PLACEHOLDARR_WEBHOOKS_ENABLED', 'true').lower() == 'true',
                    'discord_webhook': os.environ.get('DISCORD_WEBHOOK_URL', ''),
                },
                'monitoring': {
                    'queue_monitoring': os.environ.get('PLACEHOLDARR_QUEUE_MONITORING', 'true').lower() == 'true',
                    'health_check_interval': int(os.environ.get('PLACEHOLDARR_HEALTH_CHECK_INTERVAL', '60')),
                }
            }
            
            # Service-specific configurations
            if 'plex' in self.enabled_services:
                self.config['plex'] = {
                    'enabled': True,
                    'url': os.environ.get('PLACEHOLDARR_PLEX_URL', 'http://surge-plex:32400'),
                    'token': self.api_keys.get('plex', ''),
                    'library_refresh': os.environ.get('PLACEHOLDARR_PLEX_LIBRARY_REFRESH', 'true').lower() == 'true',
                }
            
            if 'radarr' in self.enabled_services and 'radarr' in self.api_keys:
                self.config['radarr'] = {
                    'enabled': True,
                    'url': os.environ.get('PLACEHOLDARR_RADARR_URL', 'http://surge-radarr:7878'),
                    'api_key': self.api_keys['radarr'],
                    'monitor_queue': True,
                    'root_folders': [f'{self.storage_path}/media/Movies'],
                }
            
            if 'sonarr' in self.enabled_services and 'sonarr' in self.api_keys:
                self.config['sonarr'] = {
                    'enabled': True,
                    'url': os.environ.get('PLACEHOLDARR_SONARR_URL', 'http://surge-sonarr:8989'),
                    'api_key': self.api_keys['sonarr'],
                    'monitor_queue': True,
                    'root_folders': [f'{self.storage_path}/media/TV Series'],
                }
            
            self.log("Configuration settings loaded successfully", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error loading configuration settings: {e}", "ERROR")
            return False

    def create_placeholder_files(self) -> bool:
        """Create placeholder files if they don't exist."""
        try:
            self.log("Creating placeholder files...", "INFO")
            
            placeholder_files = [
                (self.config['placeholders']['file_path'], "dummy.mp4"),
                (self.config['placeholders']['coming_soon_file_path'], "coming_soon.mkv")
            ]
            
            for file_path, filename in placeholder_files:
                path_obj = Path(file_path)
                
                if not path_obj.exists():
                    # Create parent directories
                    path_obj.parent.mkdir(parents=True, exist_ok=True)
                    
                    # Create a minimal placeholder file
                    with open(path_obj, 'wb') as f:
                        # Write minimal MP4 header for compatibility
                        if filename.endswith('.mp4'):
                            # Minimal MP4 file (just header)
                            f.write(b'\x00\x00\x00\x18ftypmp42\x00\x00\x00\x00mp42isom')
                        else:
                            # Minimal MKV file
                            f.write(b'\x1a\x45\xdf\xa3\xa3\x42\x86\x81\x01\x42\xf7\x81\x01\x42\xf2\x81\x04')
                    
                    self.log(f"Created placeholder file: {path_obj}", "SUCCESS")
                else:
                    self.log(f"Placeholder file exists: {path_obj}", "INFO")
            
            return True
            
        except Exception as e:
            self.log(f"Error creating placeholder files: {e}", "ERROR")
            return False

    def generate_configuration_file(self) -> bool:
        """Generate the Placeholdarr configuration file."""
        try:
            self.log("Generating Placeholdarr configuration file...", "INFO")
            
            # Add metadata to config
            config_with_metadata = {
                '_metadata': {
                    'generated_by': 'Surge Placeholdarr Configurator',
                    'generated_at': time.strftime('%Y-%m-%d %H:%M:%S'),
                    'version': '1.0'
                }
            }
            
            # Merge with main configuration
            config_with_metadata.update(self.config)
            
            # Write YAML configuration file
            with open(self.config_file, 'w') as f:
                yaml.dump(config_with_metadata, f, 
                         default_flow_style=False,
                         sort_keys=False,
                         indent=2)
            
            self.log(f"Configuration file created: {self.config_file}", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error generating configuration file: {e}", "ERROR")
            return False

    def validate_configuration(self) -> bool:
        """Validate Placeholdarr configuration."""
        try:
            self.log("Validating Placeholdarr configuration...", "INFO")
            
            # Check if at least one service is configured
            if not any(key in self.config for key in ['radarr', 'sonarr', 'plex']):
                self.log("No services configured - Placeholdarr needs at least one service connection", "ERROR")
                return False
            
            # Validate placeholder files
            placeholder_files = [
                self.config['placeholders']['file_path'],
                self.config['placeholders']['coming_soon_file_path']
            ]
            
            for file_path in placeholder_files:
                if not os.path.exists(file_path):
                    self.log(f"Placeholder file missing: {file_path}", "ERROR")
                    return False
            
            # Validate strategy
            valid_strategies = ['hardlink', 'symlink', 'copy']
            strategy = self.config['placeholders']['strategy']
            if strategy not in valid_strategies:
                self.log(f"Invalid placeholder strategy: {strategy}. Must be one of: {valid_strategies}", "ERROR")
                return False
            
            # Test service connections
            services_configured = []
            if self.config.get('radarr', {}).get('enabled'):
                services_configured.append('Radarr')
            if self.config.get('sonarr', {}).get('enabled'):
                services_configured.append('Sonarr')
            if self.config.get('plex', {}).get('enabled'):
                services_configured.append('Plex')
            
            self.log(f"Services configured: {', '.join(services_configured)}", "SUCCESS")
            
            self.log("Configuration validation completed", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"Error validating configuration: {e}", "ERROR")
            return False

    def test_service_connections(self) -> bool:
        """Test connections to configured services."""
        try:
            self.log("Testing service connections...", "INFO")
            
            # Test Radarr connection
            if self.config.get('radarr', {}).get('enabled'):
                try:
                    import requests
                    radarr_config = self.config['radarr']
                    response = requests.get(
                        f"{radarr_config['url']}/api/v3/system/status",
                        headers={'X-Api-Key': radarr_config['api_key']},
                        timeout=10
                    )
                    if response.status_code == 200:
                        self.log("Radarr connection successful", "SUCCESS")
                    else:
                        self.log(f"Radarr connection failed: HTTP {response.status_code}", "WARNING")
                except Exception as e:
                    self.log(f"Could not test Radarr connection: {e}", "WARNING")
            
            # Test Sonarr connection
            if self.config.get('sonarr', {}).get('enabled'):
                try:
                    import requests
                    sonarr_config = self.config['sonarr']
                    response = requests.get(
                        f"{sonarr_config['url']}/api/v3/system/status",
                        headers={'X-Api-Key': sonarr_config['api_key']},
                        timeout=10
                    )
                    if response.status_code == 200:
                        self.log("Sonarr connection successful", "SUCCESS")
                    else:
                        self.log(f"Sonarr connection failed: HTTP {response.status_code}", "WARNING")
                except Exception as e:
                    self.log(f"Could not test Sonarr connection: {e}", "WARNING")
            
            # Test Plex connection
            if self.config.get('plex', {}).get('enabled') and self.config['plex'].get('token'):
                try:
                    import requests
                    plex_config = self.config['plex']
                    response = requests.get(
                        f"{plex_config['url']}/identity",
                        headers={'X-Plex-Token': plex_config['token']},
                        timeout=10
                    )
                    if response.status_code == 200:
                        self.log("Plex connection successful", "SUCCESS")
                    else:
                        self.log(f"Plex connection failed: HTTP {response.status_code}", "WARNING")
                except Exception as e:
                    self.log(f"Could not test Plex connection: {e}", "WARNING")
            
            return True
            
        except Exception as e:
            self.log(f"Error testing service connections: {e}", "ERROR")
            return False

    def display_configuration_summary(self):
        """Display a summary of the Placeholdarr configuration."""
        self.log("=== Placeholdarr Configuration Summary ===", "INFO")
        
        print(f"\n🔧 General Settings:")
        print(f"   Log Level: {self.config['general']['log_level']}")
        print(f"   Check Interval: {self.config['general']['check_interval']} seconds")
        print(f"   Cleanup Interval: {self.config['general']['cleanup_interval']} minutes")
        
        print(f"\n📄 Placeholder Configuration:")
        print(f"   Strategy: {self.config['placeholders']['strategy']}")
        print(f"   Dummy File: {self.config['placeholders']['file_path']}")
        print(f"   Coming Soon File: {self.config['placeholders']['coming_soon_file_path']}")
        print(f"   Min File Size: {self.config['placeholders']['min_file_size']} bytes")
        
        print(f"\n🔗 Service Integrations:")
        if self.config.get('radarr', {}).get('enabled'):
            print(f"   ✓ Radarr: {self.config['radarr']['url']}")
        if self.config.get('sonarr', {}).get('enabled'):
            print(f"   ✓ Sonarr: {self.config['sonarr']['url']}")
        if self.config.get('plex', {}).get('enabled'):
            print(f"   ✓ Plex: {self.config['plex']['url']}")
        
        print(f"\n📊 Monitoring:")
        print(f"   Queue Monitoring: {'✓' if self.config['monitoring']['queue_monitoring'] else '✗'}")
        print(f"   Health Check Interval: {self.config['monitoring']['health_check_interval']} seconds")
        
        print(f"\n🔔 Notifications:")
        if self.config['webhooks']['enabled'] and self.config['webhooks']['discord_webhook']:
            print(f"   ✓ Discord webhooks configured")
        else:
            print(f"   ✗ No webhook notifications configured")
        
        print(f"\n📁 Files Generated:")
        print(f"   Configuration: {self.config_file}")
        print(f"   Placeholder Files: Created")
        
        print(f"\n🚀 Next Steps:")
        print(f"   1. Restart the Placeholdarr container to apply settings")
        print(f"   2. Monitor queue processing in logs")
        print(f"   3. Verify placeholder files are created for queued items")
        
        if not self.config.get('radarr') and not self.config.get('sonarr'):
            print(f"\n⚠️  Note: No *arr services configured")
            print(f"     Placeholdarr works best with Radarr/Sonarr integration")

def main():
    """Main execution function."""
    if len(sys.argv) < 2:
        print("Usage: python3 configure-placeholdarr.py <storage_path>")
        sys.exit(1)
    
    storage_path = sys.argv[1]
    configurator = SurgePlaceholdarrConfigurator(storage_path)
    
    try:
        # Configuration process
        if not configurator.create_directories():
            sys.exit(1)
        
        if not configurator.discover_service_api_keys():
            configurator.log("Continuing with limited functionality - some services may not be available", "WARNING")
        
        if not configurator.load_configuration_settings():
            sys.exit(1)
        
        if not configurator.create_placeholder_files():
            sys.exit(1)
        
        if not configurator.validate_configuration():
            sys.exit(1)
        
        if not configurator.generate_configuration_file():
            sys.exit(1)
        
        configurator.test_service_connections()
        
        configurator.display_configuration_summary()
        
        configurator.log("Placeholdarr configuration completed successfully!", "SUCCESS")
        return 0
        
    except KeyboardInterrupt:
        configurator.log("Configuration interrupted by user", "WARNING")
        return 1
    except Exception as e:
        configurator.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
