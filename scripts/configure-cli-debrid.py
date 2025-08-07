#!/usr/bin/env python3

"""
CLI-Debrid Automation Configuration

This script automatically configures CLI-Debrid for the Surge media stack.
It handles debrid service integration and configures connections with Radarr and Sonarr.

Key Features:
- Multi-debrid service support (Real-Debrid, AllDebrid, Premiumize)
- Automatic download client configuration for *arr services
- Configuration file generation
- Directory structure creation
"""

import os
import sys
import json
import time
import requests
from pathlib import Path
from typing import Optional

class CLIDebridConfigurator:
    """Main CLI-Debrid configuration class"""
    
    def __init__(self, storage_path: str = "/opt/surge"):
        self.storage_path = self._validate_storage_path(storage_path)
        self.cli_debrid_config_dir = Path(self.storage_path) / "cli_debrid" / "config"
        self.cli_debrid_downloads_dir = Path(self.storage_path) / "cli_debrid" / "downloads"
        
        # Service URLs (using Docker network names)
        self.radarr_url = "http://radarr:7878"
        self.sonarr_url = "http://sonarr:8989"
        self.cli_debrid_url = "http://cli-debrid:5000"
        
        # API Keys from environment
        self.rd_api_key = os.environ.get('RD_API_TOKEN', '')
        self.ad_api_key = os.environ.get('AD_API_TOKEN', '')
        self.premiumize_api_key = os.environ.get('PREMIUMIZE_API_TOKEN', '')
        
    def _validate_storage_path(self, path: str) -> str:
        """Validate storage path for security"""
        try:
            path_obj = Path(path).resolve()
            # Ensure path is absolute
            if not path_obj.is_absolute():
                raise ValueError("Storage path must be absolute")
            return str(path_obj)
        except Exception as e:
            print(f"⚠️  Invalid storage path '{path}': {e}")
            return "/opt/surge"  # Fallback to safe default
        
    def ensure_directories(self):
        """Create necessary directories for CLI-Debrid"""
        print("📁 Creating CLI-Debrid directories...")
        
        directories = [
            self.cli_debrid_config_dir,
            self.cli_debrid_downloads_dir,
            self.cli_debrid_downloads_dir / "movies",
            self.cli_debrid_downloads_dir / "tv"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"  ✓ Created: {directory}")
            
    def wait_for_service(self, service_name: str, url: str, max_attempts: int = 30) -> bool:
        """Wait for a service to become available"""
        print(f"⏳ Waiting for {service_name} to be ready...")
        
        for attempt in range(max_attempts):
            try:
                response = requests.get(f"{url}/ping", timeout=5)
                if response.status_code == 200:
                    print(f"  ✓ {service_name} is ready!")
                    return True
            except requests.exceptions.RequestException:
                pass
            
            if attempt < max_attempts - 1:
                print(f"  ⏳ Attempt {attempt + 1}/{max_attempts}, retrying in 10s...")
                time.sleep(10)
        
        # Try alternative endpoints
        try:
            if "cli-debrid" in url.lower():
                response = requests.get(f"{url}/api/v1/status", timeout=5)
            elif "radarr" in url.lower() or "sonarr" in url.lower():
                response = requests.get(f"{url}/api/v3/system/status", timeout=5, headers={'X-Api-Key': 'dummy'})
            
            if response.status_code in [200, 401]:  # 401 means service is up but needs auth
                print(f"  ✓ {service_name} is responding!")
                return True
        except requests.exceptions.RequestException:
            pass
            
        print(f"  ⚠️  {service_name} not responding, continuing anyway...")
        return False
        
    def get_api_key(self, service_name: str, base_url: str, config_path: str) -> Optional[str]:
        """Extract API key from service configuration"""
        try:
            config_file = Path(config_path) / "config.xml"
            if config_file.exists():
                with open(config_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Extract API key using basic string parsing
                if '<ApiKey>' in content and '</ApiKey>' in content:
                    start = content.find('<ApiKey>') + 8
                    end = content.find('</ApiKey>')
                    api_key = content[start:end].strip()
                    if api_key and len(api_key) > 10:
                        print(f"  ✓ Found {service_name} API key")
                        return api_key
                        
        except Exception as e:
            print(f"  ⚠️  Could not read {service_name} API key: {e}")
            
        return None
        
    def create_cli_debrid_config(self):
        """Generate CLI-Debrid configuration file"""
        print("📝 Generating CLI-Debrid configuration...")
        
        # Determine which debrid services are available
        available_services = []
        primary_service = None
        
        if self.rd_api_key:
            available_services.append({
                'name': 'real-debrid',
                'api_key': self.rd_api_key,
                'enabled': True,
                'priority': 1
            })
            primary_service = 'real-debrid'
            
        if self.ad_api_key:
            available_services.append({
                'name': 'alldebrid',
                'api_key': self.ad_api_key,
                'enabled': True,
                'priority': 2
            })
            if not primary_service:
                primary_service = 'alldebrid'
                
        if self.premiumize_api_key:
            available_services.append({
                'name': 'premiumize',
                'api_key': self.premiumize_api_key,
                'enabled': True,
                'priority': 3
            })
            if not primary_service:
                primary_service = 'premiumize'
                
        if not available_services:
            print("  ⚠️  No debrid API keys found in environment!")
            print("  💡 Please set RD_API_TOKEN, AD_API_TOKEN, or PREMIUMIZE_API_TOKEN")
            return False
            
        print(f"  ✓ Found {len(available_services)} debrid service(s)")
        print(f"  ✓ Primary service: {primary_service}")
        
        # Create CLI-Debrid configuration
        config = {
            'version': '1.0',
            'server': {
                'host': '0.0.0.0',
                'port': 5000,
                'debug': False
            },
            'debrid_services': {
                'primary': primary_service,
                'services': {}
            },
            'download_settings': {
                'download_directory': '/downloads',
                'max_concurrent_downloads': 5,
                'check_interval_seconds': 30,
                'cleanup_completed': False,
                'create_subdirectories': True
            },
            'quality_settings': {
                'preferred_quality': '1080p',
                'fallback_quality': '720p',
                'min_file_size_mb': 100,
                'max_file_size_gb': 50,
                'preferred_codecs': ['h264', 'h265'],
                'blocked_qualities': ['cam', 'ts']
            },
            'organization': {
                'create_movie_folders': True,
                'create_tv_folders': True,
                'movie_folder_format': '{title} ({year})',
                'tv_folder_format': '{title}/Season {season:02d}',
                'cleanup_empty_folders': True
            },
            'notifications': {
                'discord': {
                    'enabled': bool(os.environ.get('DISCORD_WEBHOOK_URL')),
                    'webhook_url': os.environ.get('DISCORD_WEBHOOK_URL', ''),
                    'notify_on': ['download_complete', 'download_failed', 'service_error']
                }
            },
            'logging': {
                'level': 'INFO',
                'file_logging': True,
                'log_file': '/app/config/cli_debrid.log',
                'max_log_size_mb': 50,
                'log_rotation_count': 5
            }
        }
        
        # Add debrid service configurations
        for service in available_services:
            config['debrid_services']['services'][service['name']] = {
                'api_key': service['api_key'],
                'enabled': service['enabled'],
                'priority': service['priority'],
                'timeout_seconds': 30,
                'retry_attempts': 3
            }
            
        # Save configuration
        config_file = self.cli_debrid_config_dir / "config.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
            
        print(f"  ✓ Configuration saved to: {config_file}")
        return True
        
    def configure_arr_download_client(self, service_name: str, service_url: str, api_key: str):
        """Configure CLI-Debrid as download client in Radarr/Sonarr"""
        print(f"🔗 Configuring {service_name} download client...")
        
        if not api_key:
            print(f"  ⚠️  No API key available for {service_name}")
            return False
            
        try:
            headers = {"X-Api-Key": api_key, "Content-Type": "application/json"}
            
            # Check if CLI-Debrid client already exists
            response = requests.get(f"{service_url}/api/v3/downloadclient", headers=headers, timeout=10)
            if response.status_code == 200:
                existing_clients = response.json()
                for client in existing_clients:
                    if client.get('name') == 'CLI-Debrid':
                        print(f"  ✓ CLI-Debrid download client already configured in {service_name}")
                        return True
                        
            # Create CLI-Debrid download client configuration
            download_client_config = {
                "enable": True,
                "name": "CLI-Debrid",
                "implementation": "TorrentBlackhole",  # Using blackhole implementation for debrid
                "configContract": "TorrentBlackholeSettings",
                "priority": 10,
                "removeCompletedDownloads": False,
                "removeFailedDownloads": True,
                "fields": [
                    {
                        "name": "torrentFolder",
                        "value": "/downloads/blackhole/torrents"
                    },
                    {
                        "name": "watchFolder",
                        "value": "/downloads/completed"
                    },
                    {
                        "name": "saveMagnetFiles",
                        "value": True
                    },
                    {
                        "name": "magnetFileExtension",
                        "value": ".magnet"
                    }
                ],
                "tags": ["debrid", "cli-debrid"]
            }
            
            response = requests.post(
                f"{service_url}/api/v3/downloadclient",
                headers=headers,
                json=download_client_config,
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                print(f"  ✓ CLI-Debrid download client configured in {service_name}")
                return True
            else:
                print(f"  ⚠️  Failed to configure download client in {service_name}: {response.status_code}")
                print(f"      Response: {response.text[:200]}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"  ⚠️  Error configuring {service_name}: {e}")
            return False
            
    def create_integration_scripts(self):
        """Create helper scripts for CLI-Debrid integration"""
        print("📝 Creating integration scripts...")
        
        # Create blackhole directories
        blackhole_dir = self.cli_debrid_downloads_dir / "blackhole"
        torrents_dir = blackhole_dir / "torrents"
        completed_dir = self.cli_debrid_downloads_dir / "completed"
        
        for directory in [blackhole_dir, torrents_dir, completed_dir]:
            directory.mkdir(parents=True, exist_ok=True)
            
        # Create torrent processing script
        processor_script = self.cli_debrid_config_dir / "process_torrents.py"
        script_content = '''#!/usr/bin/env python3
"""
CLI-Debrid Torrent Processor
Monitors blackhole directory and processes torrents through debrid services
"""

import os
import time
import json
import requests
import shutil
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class TorrentProcessor(FileSystemEventHandler):
    def __init__(self, config_file):
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        self.api_base = f"http://localhost:{self.config['server']['port']}/api/v1"
        
    def on_created(self, event):
        if not event.is_dir and (event.src_path.endswith('.torrent') or event.src_path.endswith('.magnet')):
            self.process_torrent(event.src_path)
            
    def process_torrent(self, torrent_path):
        try:
            # Send to CLI-Debrid for processing
            files = {'torrent': open(torrent_path, 'rb')} if torrent_path.endswith('.torrent') else None
            data = {'magnet': open(torrent_path, 'r').read()} if torrent_path.endswith('.magnet') else {}
            
            response = requests.post(f"{self.api_base}/add", files=files, data=data)
            if response.status_code == 200:
                print(f"✓ Processed: {Path(torrent_path).name}")
                # Move processed file
                shutil.move(torrent_path, Path(torrent_path).parent.parent / 'processed' / Path(torrent_path).name)
            else:
                print(f"✗ Failed to process: {Path(torrent_path).name}")
                
        except Exception as e:
            print(f"Error processing {torrent_path}: {e}")

if __name__ == "__main__":
    config_file = "/app/config/config.json"
    watch_dir = "/downloads/blackhole/torrents"
    
    # Ensure processed directory exists
    Path("/downloads/blackhole/processed").mkdir(exist_ok=True)
    
    event_handler = TorrentProcessor(config_file)
    observer = Observer()
    observer.schedule(event_handler, watch_dir, recursive=False)
    observer.start()
    
    print(f"Monitoring {watch_dir} for torrents...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
'''
        
        with open(processor_script, 'w', encoding='utf-8') as f:
            f.write(script_content)
            
        # Make script executable with restricted permissions
        os.chmod(processor_script, 0o750)  # Owner and group only
        
        print(f"  ✓ Created torrent processor: {processor_script}")
        
        # Create systemd-style service definition for the processor
        service_def = self.cli_debrid_config_dir / "torrent-processor.service"
        service_content = '''[Unit]
Description=CLI-Debrid Torrent Processor
After=cli-debrid.service
Requires=cli-debrid.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /app/config/process_torrents.py
Restart=always
RestartSec=10
User=root
WorkingDirectory=/app/config

[Install]
WantedBy=multi-user.target
'''
        
        with open(service_def, 'w', encoding='utf-8') as f:
            f.write(service_content)
            
        print(f"  ✓ Created service definition: {service_def}")
        return True
        
    def test_debrid_services(self):
        """Test configured debrid services"""
        print("🧪 Testing debrid service connections...")
        
        services_tested = []
        
        if self.rd_api_key:
            try:
                headers = {'Authorization': f'Bearer {self.rd_api_key}'}
                response = requests.get('https://api.real-debrid.com/rest/1.0/user', headers=headers, timeout=10)
                if response.status_code == 200:
                    user_data = response.json()
                    print(f"  ✓ Real-Debrid: Connected as {user_data.get('username', 'Unknown')}")
                    services_tested.append('real-debrid')
                else:
                    print(f"  ⚠️  Real-Debrid: Authentication failed ({response.status_code})")
            except requests.exceptions.RequestException as e:
                print(f"  ⚠️  Real-Debrid: Network error - {type(e).__name__}")
            except Exception as e:
                print(f"  ⚠️  Real-Debrid: Unexpected error - {type(e).__name__}")
                
        if self.ad_api_key:
            try:
                params = {'apikey': self.ad_api_key}
                response = requests.get('https://api.alldebrid.com/v4/user', params=params, timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    if data.get('status') == 'success':
                        user_data = data.get('data', {}).get('user', {})
                        print(f"  ✓ AllDebrid: Connected as {user_data.get('username', 'Unknown')}")
                        services_tested.append('alldebrid')
                    else:
                        print(f"  ⚠️  AllDebrid: API error - {data.get('error', 'Unknown')}")
                else:
                    print(f"  ⚠️  AllDebrid: Request failed ({response.status_code})")
            except requests.exceptions.RequestException as e:
                print(f"  ⚠️  AllDebrid: Network error - {type(e).__name__}")
            except Exception as e:
                print(f"  ⚠️  AllDebrid: Unexpected error - {type(e).__name__}")
                
        if self.premiumize_api_key:
            try:
                headers = {'Authorization': f'Bearer {self.premiumize_api_key}'}
                response = requests.get('https://www.premiumize.me/api/account/info', headers=headers, timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    if data.get('status') == 'success':
                        print(f"  ✓ Premiumize: Connected successfully")
                        services_tested.append('premiumize')
                    else:
                        print(f"  ⚠️  Premiumize: API error - {data.get('message', 'Unknown')}")
                else:
                    print(f"  ⚠️  Premiumize: Request failed ({response.status_code})")
            except requests.exceptions.RequestException as e:
                print(f"  ⚠️  Premiumize: Network error - {type(e).__name__}")
            except Exception as e:
                print(f"  ⚠️  Premiumize: Unexpected error - {type(e).__name__}")
                
        if services_tested:
            print(f"  ✅ Successfully tested {len(services_tested)} debrid service(s)")
            return True
        else:
            print("  ⚠️  No debrid services could be verified")
            return False
            
    def create_status_script(self):
        """Create a status checking script for CLI-Debrid"""
        print("📝 Creating status checking script...")
        
        status_script = self.cli_debrid_config_dir / "check_status.py"
        script_content = '''#!/usr/bin/env python3
"""CLI-Debrid Status Checker"""

import json
import requests
import sys
from pathlib import Path

def check_status():
    config_file = Path("/app/config/config.json")
    if not config_file.exists():
        print("❌ Configuration file not found")
        return False
        
    with open(config_file, 'r') as f:
        config = json.load(f)
        
    # Check CLI-Debrid service
    try:
        response = requests.get(f"http://localhost:{config['server']['port']}/api/v1/status", timeout=5)
        if response.status_code == 200:
            print("✅ CLI-Debrid service is running")
            data = response.json()
            print(f"   Version: {data.get('version', 'Unknown')}")
            print(f"   Uptime: {data.get('uptime', 'Unknown')}")
        else:
            print("⚠️  CLI-Debrid service not responding")
    except Exception as e:
        print(f"❌ CLI-Debrid service error: {e}")
        
    # Check debrid services
    for service_name, service_config in config.get('debrid_services', {}).get('services', {}).items():
        if service_config.get('enabled'):
            print(f"✅ {service_name}: Configured and enabled")
        else:
            print(f"⚠️  {service_name}: Configured but disabled")
            
    # Check download directory
    downloads_dir = Path("/downloads")
    if downloads_dir.exists():
        total_files = len(list(downloads_dir.rglob("*")))
        print(f"📁 Downloads directory: {total_files} total files")
    else:
        print("⚠️  Downloads directory not found")
        
    return True

if __name__ == "__main__":
    check_status()
'''
        
        with open(status_script, 'w', encoding='utf-8') as f:
            f.write(script_content)
            
        os.chmod(status_script, 0o755)
        print(f"  ✓ Created status script: {status_script}")
        
    def run_configuration(self):
        """Main configuration process"""
        print("🚀 Starting CLI-Debrid configuration...")
        print(f"   Storage path: {self.storage_path}")
        print(f"   Config directory: {self.cli_debrid_config_dir}")
        
        success_count = 0
        total_steps = 6
        
        # Step 1: Create directories
        try:
            self.ensure_directories()
            success_count += 1
            print("✅ Step 1/6: Directory structure created")
        except Exception as e:
            print(f"❌ Step 1/6 failed: {e}")
            
        # Step 2: Test debrid services
        try:
            if self.test_debrid_services():
                success_count += 1
                print("✅ Step 2/6: Debrid services tested")
            else:
                print("⚠️  Step 2/6: Some debrid services failed")
        except Exception as e:
            print(f"❌ Step 2/6 failed: {e}")
            
        # Step 3: Create CLI-Debrid configuration
        try:
            if self.create_cli_debrid_config():
                success_count += 1
                print("✅ Step 3/6: CLI-Debrid configuration created")
            else:
                print("⚠️  Step 3/6: Configuration created with warnings")
        except Exception as e:
            print(f"❌ Step 3/6 failed: {e}")
            
        # Step 4: Wait for services and get API keys
        api_keys = {}
        
        # Get Radarr API key
        radarr_api_key = self.get_api_key("Radarr", self.radarr_url, f"{self.storage_path}/Radarr/config")
        if radarr_api_key:
            api_keys['radarr'] = radarr_api_key
            
        # Get Sonarr API key  
        sonarr_api_key = self.get_api_key("Sonarr", self.sonarr_url, f"{self.storage_path}/Sonarr/config")
        if sonarr_api_key:
            api_keys['sonarr'] = sonarr_api_key
            
        if api_keys:
            success_count += 1
            print("✅ Step 4/6: Service API keys retrieved")
        else:
            print("⚠️  Step 4/6: Could not retrieve all API keys")
            
        # Step 5: Configure *arr download clients
        arr_configured = 0
        
        if api_keys.get('radarr'):
            if self.configure_arr_download_client("Radarr", self.radarr_url, api_keys['radarr']):
                arr_configured += 1
                
        if api_keys.get('sonarr'):
            if self.configure_arr_download_client("Sonarr", self.sonarr_url, api_keys['sonarr']):
                arr_configured += 1
                
        if arr_configured > 0:
            success_count += 1
            print("✅ Step 5/6: *arr services configured")
        else:
            print("⚠️  Step 5/6: *arr service configuration incomplete")
            
        # Step 6: Create integration and status scripts
        try:
            self.create_integration_scripts()
            self.create_status_script()
            success_count += 1
            print("✅ Step 6/6: Integration scripts created")
        except Exception as e:
            print(f"❌ Step 6/6 failed: {e}")
            
        # Final summary
        print(f"\n🎯 CLI-Debrid configuration completed!")
        print(f"   ✅ {success_count}/{total_steps} steps successful")
        
        if success_count >= 4:
            print("✅ CLI-Debrid is ready for use!")
            print("\n📋 Next steps:")
            print("   1. Access CLI-Debrid web interface at: http://localhost:5000")
            print("   2. Verify debrid service connections")
            print("   3. Test download functionality with *arr services")
            print("   4. Monitor logs: docker logs surge-cli-debrid")
            
            # Show configuration summary
            print(f"\n📁 Configuration files:")
            print(f"   • Main config: {self.cli_debrid_config_dir}/config.json")
            print(f"   • Status script: {self.cli_debrid_config_dir}/check_status.py")
            print(f"   • Torrent processor: {self.cli_debrid_config_dir}/process_torrents.py")
            
            return True
        else:
            print("⚠️  CLI-Debrid configuration completed with issues")
            print("💡 Check the output above for specific problems")
            return False

def main():
    """Main entry point"""
    storage_path = sys.argv[1] if len(sys.argv) > 1 else "/opt/surge"
    
    print("=" * 60)
    print("🔧 CLI-DEBRID AUTOMATED CONFIGURATION")
    print("=" * 60)
    
    configurator = CLIDebridConfigurator(storage_path)
    success = configurator.run_configuration()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
