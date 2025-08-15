#!/usr/bin/env python3
"""
Surge Service Interconnection Manager

Automatically configures all service interconnections for enabled services.
This script handles:
- API key discovery and injection
- Service-to-service connections
- Download client configurations
- Library and metadata integrations
- Notification setups
"""

import os
import sys
import json
import time
import xml.etree.ElementTree as ET
import configparser
import requests
import urllib.request
import yaml
from datetime import datetime
from pathlib import Path

class SurgeInterconnectionManager:
    
    def _generate_secure_nzbget_password(self):
        """Generate a secure password for NZBGet if none provided"""
        import secrets, string
        password = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(16))
        self.log(f"⚠️  Generated secure NZBGet password: {password}", "WARNING")
        self.log("⚠️  Please set NZBGET_PASS in your .env file for persistence", "WARNING")
        return password
    def __init__(self, storage_path=None):
        self.storage_path = storage_path or self.find_storage_path()
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        
        # Load environment variables
        self.load_env()
        
        # Service detection
        self.enabled_services = self.detect_enabled_services()
        
        # API keys storage
        self.api_keys = {}
        
        self.log("Surge Interconnection Manager initialized", "INFO")
        self.log(f"Storage path: {self.storage_path}", "INFO")
        self.log(f"Enabled services: {', '.join(self.enabled_services)}", "INFO")
    
    def find_storage_path(self):
        """Require user-set STORAGE_PATH from environment or .env file."""
        storage_path = os.environ.get('STORAGE_PATH')
        if not storage_path:
            self.log("STORAGE_PATH environment variable is not set. Please set it before running the script.", "ERROR")
            sys.exit(1)
        if not os.path.exists(storage_path):
            self.log(f"STORAGE_PATH '{storage_path}' does not exist. Please check your configuration.", "ERROR")
            sys.exit(1)
        return storage_path
    
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
        
        # Check for service enablement environment variables
        service_checks = {
            'plex': os.environ.get('MEDIA_SERVER') == 'plex',
            'emby': os.environ.get('MEDIA_SERVER') == 'emby',
            'jellyfin': os.environ.get('MEDIA_SERVER') == 'jellyfin',
            'radarr': True,  # Always enabled
            'sonarr': True,  # Always enabled
            'prowlarr': True,  # Always enabled
            'bazarr': os.environ.get('ENABLE_BAZARR', 'false').lower() == 'true',
            'overseerr': True,  # Always enabled
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
    
    def wait_for_service(self, service, port, timeout=60):
        """Wait for a service to be ready."""
        self.log(f"Waiting for {service} on port {port}...", "INFO")
        
        for attempt in range(timeout):
            try:
                response = requests.get(f"http://localhost:{port}", timeout=2)
                if response.status_code < 500:
                    self.log(f"{service} is ready!", "SUCCESS")
                    return True
            except:
                pass
            
            if attempt % 10 == 0:
                self.log(f"Still waiting for {service}... ({attempt}/{timeout})", "INFO")
            
            time.sleep(1)
        
        self.log(f"{service} failed to become ready after {timeout} seconds", "WARNING")
        return False
    
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
            self.log(f"Error reading API key from {config_path}: {e}", "ERROR")
        
        return None
    
    def discover_api_keys(self):
        """Discover API keys for all enabled services."""
        self.log("Discovering API keys...", "INFO")
        
        # Service config paths
        config_paths = {
            'radarr': f"{self.storage_path}/Radarr/config/config.xml",
            'sonarr': f"{self.storage_path}/Sonarr/config/config.xml", 
            'prowlarr': f"{self.storage_path}/Prowlarr/config/config.xml",
            'bazarr': f"{self.storage_path}/Bazarr/config/config/config.yaml",
            'overseerr': f"{self.storage_path}/Overseerr/config/settings.json",
            'tautulli': f"{self.storage_path}/Tautulli/config/config.ini"
        }
        
        # Get XML-based API keys
        for service in ['radarr', 'sonarr', 'prowlarr']:
            if service in self.enabled_services:
                api_key = self.get_api_key_from_xml(config_paths[service])
                if api_key:
                    self.api_keys[service] = api_key
                    self.log(f"Found {service} API key: {api_key[:8]}...", "SUCCESS")
                else:
                    self.log(f"Could not find {service} API key", "WARNING")
        
        # Get Bazarr API key from INI
        if 'bazarr' in self.enabled_services:
            self.api_keys['bazarr'] = self.get_bazarr_api_key()
        
        # Get Tautulli API key from INI
        if 'tautulli' in self.enabled_services:
            self.api_keys['tautulli'] = self.get_tautulli_api_key()
    
    def get_bazarr_api_key(self):
        """Get Bazarr API key from config.yaml."""
        config_path = f"{self.storage_path}/Bazarr/config/config/config.yaml"
        
        try:
            if os.path.exists(config_path):
                with open(config_path, 'r') as f:
                    config = yaml.safe_load(f)
                
                # Bazarr API key is typically under 'auth' -> 'apikey'
                if config and 'auth' in config and 'apikey' in config['auth']:
                    api_key = config['auth']['apikey']
                    if api_key:
                        self.log(f"Found Bazarr API key: {api_key[:8]}...", "SUCCESS")
                        return api_key
        except Exception as e:
            self.log(f"Error reading Bazarr config: {e}", "ERROR")
        
        return None
    
    def get_tautulli_api_key(self):
        """Get Tautulli API key from config.ini."""
        config_path = f"{self.storage_path}/Tautulli/config/config.ini"
        
        try:
            if os.path.exists(config_path):
                config = configparser.ConfigParser()
                config.read(config_path)
                
                if config.has_section('General') and config.has_option('General', 'api_key'):
                    api_key = config.get('General', 'api_key')
                    if api_key:
                        self.log(f"Found Tautulli API key: {api_key[:8]}...", "SUCCESS")
                        return api_key
        except Exception as e:
            self.log(f"Error reading Tautulli config: {e}", "ERROR")
        
        return None
    
    def configure_bazarr_connections(self):
        """Configure Bazarr connections to Radarr and Sonarr."""
        if 'bazarr' not in self.enabled_services:
            return
        
        self.log("Configuring Bazarr connections...", "INFO")
        
        bazarr_api = self.api_keys.get('bazarr')
        if not bazarr_api:
            self.log("Bazarr API key not available, skipping configuration", "WARNING")
            return
        
        # Configure Radarr connection
        if 'radarr' in self.enabled_services and 'radarr' in self.api_keys:
            self.add_bazarr_provider('radarr', self.api_keys['radarr'])
        
        # Configure Sonarr connection
        if 'sonarr' in self.enabled_services and 'sonarr' in self.api_keys:
            self.add_bazarr_provider('sonarr', self.api_keys['sonarr'])
    
    def add_bazarr_provider(self, service, api_key):
        """Add a provider to Bazarr configuration."""
        try:
            service_config = {
                'radarr': {
                    'url': 'http://radarr:7878',
                    'type': 'radarr'
                },
                'sonarr': {
                    'url': 'http://sonarr:8989', 
                    'type': 'sonarr'
                }
            }
            
            if service not in service_config:
                return
            
            # Make API call to add provider
            bazarr_api = self.api_keys['bazarr']
            url = f"http://localhost:6767/api/providers/{service}"
            
            payload = {
                'name': service.title(),
                'url': service_config[service]['url'],
                'apikey': api_key,
                'enabled': True
            }
            
            headers = {
                'X-API-KEY': bazarr_api,
                'Content-Type': 'application/json'
            }
            
            response = requests.post(url, json=payload, headers=headers, timeout=10)
            
            if response.status_code in [200, 201]:
                self.log(f"✅ Bazarr ↔ {service.title()} connection configured", "SUCCESS")
            else:
                self.log(f"Failed to configure Bazarr ↔ {service.title()}: {response.status_code}", "WARNING")
                
        except Exception as e:
            self.log(f"Error configuring Bazarr ↔ {service.title()}: {e}", "ERROR")
    
    def configure_download_clients(self):
        """Configure download clients in Radarr and Sonarr."""
        self.log("Configuring download clients...", "INFO")
        
        # Configure NZBGet if enabled
        if 'nzbget' in self.enabled_services:
            self.configure_nzbget_clients()
        
        # Configure RDT-Client if enabled
        if 'rdt-client' in self.enabled_services:
            self.configure_rdt_clients()
    
    def configure_nzbget_clients(self):
        """Configure NZBGet as download client in Radarr and Sonarr, ensuring categories exist."""
        self.ensure_nzbget_categories(['Movies', 'TV'])
        nzbget_user = os.environ.get('NZBGET_USER', 'admin')
        nzbget_pass = os.environ.get('NZBGET_PASS', 'password')
        for service in ['radarr', 'sonarr']:
            if service in self.enabled_services:
                if service in self.api_keys:
                    if service == 'radarr':
                        nzbget_config = {
                            'name': 'NZBGet',
                            'implementation': 'NZBGet',
                            'configContract': 'NzbgetSettings',
                            'protocol': 'usenet',
                            'enable': True,
                            'priority': 1,
                            'fields': [
                                {'name': 'host', 'value': 'surge-nzbget'},
                                {'name': 'port', 'value': 6789},
                                {'name': 'username', 'value': nzbget_user},
                                {'name': 'password', 'value': nzbget_pass},
                                {'name': 'movieCategory', 'value': 'Movies'}
                            ]
                        }
                    else:  # sonarr
                        # Ensure TV category exists before adding client
                        self.ensure_nzbget_categories(['TV'])
                        import time
                        time.sleep(2)  # Wait for NZBGet to update categories
                        nzbget_config = {
                            'name': 'NZBGet',
                            'implementation': 'NZBGet',
                            'configContract': 'NzbgetSettings',
                            'protocol': 'usenet',
                            'enable': True,
                            'priority': 1,
                            'fields': [
                                {'name': 'host', 'value': 'surge-nzbget'},
                                {'name': 'port', 'value': 6789},
                                {'name': 'username', 'value': nzbget_user},
                                {'name': 'password', 'value': nzbget_pass},
                                {'name': 'tvCategory', 'value': 'TV'}
                            ]
                        }
                    self.add_download_client(service, nzbget_config)
                else:
                    self.log(f"NZBGet integration: Missing API key for {service}. Cannot add NZBGet as download client.", "ERROR")

    def ensure_nzbget_categories(self, categories):
        """Ensure only the required categories exist in NZBGet."""
        url = "http://localhost:6789/jsonrpc"
        user = os.environ.get('NZBGET_USER', 'admin')
        password = os.environ.get('NZBGET_PASS') or 'password'
        headers = {'Content-Type': 'application/json'}
        payload = {
            "method": "config",
            "params": ["Categories"],
            "id": 1
        }
        try:
            response = requests.post(url, json=payload, headers=headers, auth=(user, password), timeout=10)
            if response.status_code == 200:
                result = response.json().get('result', [])
                existing = [cat['Name'] for cat in result]
                # Remove unwanted categories
                for category in existing:
                    if category not in categories:
                        self.log(f"Removing NZBGet category: {category}", "INFO")
                        remove_payload = {
                            "method": "configdelete",
                            "params": ["Categories", category],
                            "id": 1
                        }
                        remove_resp = requests.post(url, json=remove_payload, headers=headers, auth=(user, password), timeout=10)
                        if remove_resp.status_code == 200:
                            self.log(f"✅ NZBGet category '{category}' removed", "SUCCESS")
                        else:
                            self.log(f"Failed to remove NZBGet category '{category}': {remove_resp.status_code}", "WARNING")
                # Add missing required categories
                for category in categories:
                    if category not in existing:
                        self.log(f"Creating NZBGet category: {category}", "INFO")
                        add_payload = {
                            "method": "configappend",
                            "params": ["Categories", f"{category}"],
                            "id": 1
                        }
                        add_resp = requests.post(url, json=add_payload, headers=headers, auth=(user, password), timeout=10)
                        if add_resp.status_code == 200:
                            self.log(f"✅ NZBGet category '{category}' created", "SUCCESS")
                        else:
                            self.log(f"Failed to create NZBGet category '{category}': {add_resp.status_code}", "WARNING")
            else:
                self.log(f"Failed to fetch NZBGet categories: {response.status_code}", "WARNING")
        except Exception as e:
            self.log(f"Error ensuring NZBGet categories: {e}", "ERROR")
    
    def configure_rdt_clients(self):
        """Configure RDT-Client as download client in Radarr and Sonarr."""
        rdt_config = {
            'name': 'RDT-Client',
            'implementation': 'RTorrent',
            'configContract': 'RTorrentSettings', 
            'protocol': 'torrent',
            'enable': True,
            'priority': 1,  # <-- Move priority here
            'fields': [
                {'name': 'host', 'value': 'rdt-client'},
                {'name': 'port', 'value': 6500},
                {'name': 'urlBase', 'value': '/'},
                {'name': 'movieCategory', 'value': 'movies'},
                {'name': 'tvCategory', 'value': 'tv'},
                {'name': 'movieDirectory', 'value': '/downloads/movies'},
                {'name': 'tvDirectory', 'value': '/downloads/tv'}
            ]
        }
        # Add to Radarr
        if 'radarr' in self.enabled_services and 'radarr' in self.api_keys:
            self.add_download_client('radarr', rdt_config)
        # Add to Sonarr  
        if 'sonarr' in self.enabled_services and 'sonarr' in self.api_keys:
            self.add_download_client('sonarr', rdt_config)
    
    def add_download_client(self, service, config):
        """Add download client to service via API."""
        import traceback
        try:
            api_key = self.api_keys.get(service)
            if not api_key:
                return

            # Use localhost for API calls since the script runs on the host
            port = {'radarr': 7878, 'sonarr': 8989}[service]
            url = f"http://localhost:{port}/api/v3/downloadclient"

            headers = {
                'X-Api-Key': api_key,
                'Content-Type': 'application/json'
            }

            response = requests.post(url, json=config, headers=headers, timeout=10)

            if response.status_code in [200, 201]:
                self.log(f"✅ {config['name']} configured in {service.title()}", "SUCCESS")
            else:
                self.log(f"Failed to configure {config['name']} in {service.title()}: {response.status_code}", "WARNING")
                self.log(f"Payload sent: {json.dumps(config)}", "DEBUG")
                self.log(f"Response body: {response.text}", "DEBUG")

        except Exception as e:
            self.log(f"Error configuring download client in {service}: {e}", "ERROR")
            self.log(f"Payload sent: {json.dumps(config)}", "DEBUG")
            self.log(f"Traceback: {traceback.format_exc()}", "ERROR")
    
    def configure_gaps_integration(self):
        """Configure GAPS integration with Plex and Radarr."""
        if 'gaps' not in self.enabled_services:
            return
        
        self.log("Configuring GAPS integration...", "INFO")
        
        gaps_config_dir = f"{self.storage_path}/GAPS/config"
        os.makedirs(gaps_config_dir, exist_ok=True)
        
        gaps_config = {
            'plex': {
                'url': 'http://plex:32400',
                'token': os.environ.get('PLEX_TOKEN', ''),
                'libraries': ['Movies']
            },
            'radarr': {
                'url': 'http://radarr:7878',
                'api_key': self.api_keys.get('radarr', ''),
                'enabled': 'radarr' in self.enabled_services
            }
        }
        
        config_file = f"{gaps_config_dir}/application.yml"
        with open(config_file, 'w') as f:
            f.write(f"""# GAPS Configuration - Auto-generated
server:
  port: 8484

plex:
  url: {gaps_config['plex']['url']}
  token: {gaps_config['plex']['token']}
  libraries:
    - name: Movies
      type: movie

radarr:
  enabled: {gaps_config['radarr']['enabled']}
  url: {gaps_config['radarr']['url']}
  apiKey: {gaps_config['radarr']['api_key']}
  qualityProfileId: 1
  rootFolderPath: /movies
""")
        
        self.log("✅ GAPS configuration created", "SUCCESS")
    
    def configure_all_interconnections(self):
        """Configure all service interconnections."""
        self.log("Starting comprehensive service interconnection configuration...", "INFO")
        
        # Wait for services to be ready
        service_ports = {
            'radarr': 7878,
            'sonarr': 8989,
            'prowlarr': 9696,
            'bazarr': 6767,
            'overseerr': 5055,
            'tautulli': 8182,
            'nzbget': 6789,
            'rdt-client': 6500,
            'gaps': 8484
        }
        
        for service in self.enabled_services:
            if service in service_ports:
                self.wait_for_service(service, service_ports[service])
        
        # Discover API keys
        self.discover_api_keys()
        
        # Configure interconnections
        self.configure_bazarr_connections()
        self.configure_download_clients()
        self.configure_gaps_integration()
        
        self.log("✅ All interconnections configured successfully!", "SUCCESS")
    
    def show_configuration_summary(self):
        """Show summary of configured connections."""
        self.log("=== Configuration Summary ===", "INFO")
        
        if 'bazarr' in self.enabled_services:
            self.log("Bazarr ↔ Radarr/Sonarr: Subtitle automation", "INFO")
        
        if 'nzbget' in self.enabled_services:
            self.log("NZBGet ↔ Radarr/Sonarr: Usenet download client", "INFO")
        
        if 'rdt-client' in self.enabled_services:
            self.log("RDT-Client ↔ Radarr/Sonarr: Torrent download client", "INFO")
        
        if 'gaps' in self.enabled_services:
            self.log("GAPS ↔ Plex/Radarr: Collection gap analysis", "INFO")
        
        self.log("All configured services should now work together automatically!", "SUCCESS")

def main():
    """Main execution function."""
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    manager = SurgeInterconnectionManager(storage_path)
    
    try:
        manager.configure_all_interconnections()
        manager.show_configuration_summary()
        return 0
    except Exception as e:
        manager.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
