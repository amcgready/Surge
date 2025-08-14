class DecypharrConfigurator:
    """Main Decypharr configuration class"""
    def __init__(self, storage_path: str):
        self.storage_path = self._validate_storage_path(storage_path)
        self.decypharr_config_dir = Path(self.storage_path) / "Decypharr" / "config"
        self.decypharr_downloads_dir = Path(self.storage_path) / "downloads" / "Decypharr"
        self.decypharr_movies_dir = Path(self.storage_path) / "downloads" / "Decypharr" / "movies"
        self.decypharr_tv_dir = Path(self.storage_path) / "downloads" / "Decypharr" / "tv"
        # ...existing code...

    def generate_config_template(self):
        """Generate a commented config template exposing all variables"""
        print("📝 Generating Decypharr config template...")
        template = {
            "version": "1.0",  # Config version
            "debrids": [
                {
                    "name": "realdebrid",  # Debrid provider name
                    "api_key": "<YOUR_REALDEBRID_API_KEY>",
                    "folder": "/mnt/downloads/realdebrid/__all__",  # Folder for downloads
                    "use_webdav": True,  # Enable WebDAV
                    "webdav_url": "https://webdav.real-debrid.com",  # WebDAV URL
                    "enabled": True  # Enable this provider
                },
                {
                    "name": "alldebrid",
                    "api_key": "<YOUR_ALLDEBRID_API_KEY>",
                    "folder": "/mnt/downloads/alldebrid/__all__",
                    "use_webdav": True,
                    "webdav_url": "https://webdav.alldebrid.com",
                    "enabled": True
                },
                {
                    "name": "debridlink",
                    "api_key": "<YOUR_DEBRIDLINK_API_KEY>",
                    "folder": "/mnt/downloads/debridlink/__all__",
                    "use_webdav": True,
                    "webdav_url": "",
                    "enabled": True
                },
                {
                    "name": "torbox",
                    "api_key": "<YOUR_TORBOX_API_KEY>",
                    "folder": "/mnt/downloads/torbox/__all__",
                    "use_webdav": True,
                    "webdav_url": "",
                    "enabled": True
                }
            ],
            "qbittorrent": {
                "port": 8282,  # API port
                "download_folder": "/mnt/downloads/symlinks/",  # Download folder
                "categories": ["sonarr", "radarr", "lidarr", "readarr"],  # Supported categories
                "default_category": "default",
                "temp_folder": "/mnt/downloads/temp/",
                "completed_folder": "/mnt/downloads/completed/"
            },
            "repair": {
                "enabled": True,  # Enable repair worker
                "interval": "6h",  # Repair interval (e.g. 1h, 6h, cron syntax)
                "check_symlinks": True,  # Check for broken symlinks
                "check_missing_files": True,  # Check for missing files
                "auto_repair": True,  # Auto process repairs
                "max_retries": 3  # Max retries for repair jobs
            },
            "webdav": {
                "enabled": True,  # Enable WebDAV server
                "port": 8283,  # WebDAV port
                "prefix": "/webdav",  # WebDAV URL prefix
                "auto_mount": True  # Auto-mount WebDAV folders
            },
            "blackhole": {
                "enabled": True,  # Enable blackhole processing
                "watch_folders": {
                    "sonarr": "/mnt/downloads/blackhole/sonarr",
                    "radarr": "/mnt/downloads/blackhole/radarr"
                },
                "check_interval": "30s",  # Interval to check for new files
                "auto_process": True  # Auto process new files
            },
            "api": {
                "enable_cors": True,  # Enable CORS
                "rate_limit": {
                    "enabled": True,
                    "requests_per_minute": 60
                }
            },
            "use_auth": False,  # Enable authentication for WebUI/API
            "log_level": "info",  # Log level (info, debug, warning, error)
            "metrics": {
                "enabled": True,  # Enable metrics endpoint
                "port": 8284,  # Metrics port
                "endpoint": "/metrics"  # Metrics endpoint path
            },
            "notifications": {
                "discord": {
                    "enabled": False,  # Enable Discord notifications
                    "webhook_url": "<YOUR_DISCORD_WEBHOOK_URL>",
                    "events": ["download_complete", "download_failed", "repair_complete"]
                }
            },
            "arr": {
                "radarr": {
                    "api_key": "<YOUR_RADARR_API_KEY>",
                    "url": "http://radarr:7878"
                },
                "sonarr": {
                    "api_key": "<YOUR_SONARR_API_KEY>",
                    "url": "http://sonarr:8989"
                }
            }
        }
        # Save template
        template_file = self.decypharr_config_dir / "config.template.json"
        with open(template_file, 'w', encoding='utf-8') as f:
            json.dump(template, f, indent=2)
        print(f"  ✓ Config template saved to: {template_file}")
def generate_config_template(self):
        """Generate a commented config template exposing all variables"""
        print("📝 Generating Decypharr config template...")
        template = {
            "version": "1.0",  # Config version
            "debrids": [
                {
                    "name": "realdebrid",  # Debrid provider name
                    "api_key": "<YOUR_REALDEBRID_API_KEY>",
                    "folder": "/mnt/downloads/realdebrid/__all__",  # Folder for downloads
                    "use_webdav": True,  # Enable WebDAV
                    "webdav_url": "https://webdav.real-debrid.com",  # WebDAV URL
                    "enabled": True  # Enable this provider
                },
                {
                    "name": "alldebrid",
                    "api_key": "<YOUR_ALLDEBRID_API_KEY>",
                    "folder": "/mnt/downloads/alldebrid/__all__",
                    "use_webdav": True,
                    "webdav_url": "https://webdav.alldebrid.com",
                    "enabled": True
                },
                {
                    "name": "debridlink",
                    "api_key": "<YOUR_DEBRIDLINK_API_KEY>",
                    "folder": "/mnt/downloads/debridlink/__all__",
                    "use_webdav": True,
                    "webdav_url": "",
                    "enabled": True
                },
                {
                    "name": "torbox",
                    "api_key": "<YOUR_TORBOX_API_KEY>",
                    "folder": "/mnt/downloads/torbox/__all__",
                    "use_webdav": True,
                    "webdav_url": "",
                    "enabled": True
                }
            ],
            "qbittorrent": {
                "port": 8282,  # API port
                "download_folder": "/mnt/downloads/symlinks/",  # Download folder
                "categories": ["sonarr", "radarr", "lidarr", "readarr"],  # Supported categories
                "default_category": "default",
                "temp_folder": "/mnt/downloads/temp/",
                "completed_folder": "/mnt/downloads/completed/"
            },
            "repair": {
                "enabled": True,  # Enable repair worker
                "interval": "6h",  # Repair interval (e.g. 1h, 6h, cron syntax)
                "check_symlinks": True,  # Check for broken symlinks
                "check_missing_files": True,  # Check for missing files
                "auto_repair": True,  # Auto process repairs
                "max_retries": 3  # Max retries for repair jobs
            },
            "webdav": {
                "enabled": True,  # Enable WebDAV server
                "port": 8283,  # WebDAV port
                "prefix": "/webdav",  # WebDAV URL prefix
                "auto_mount": True  # Auto-mount WebDAV folders
            },
            "blackhole": {
                "enabled": True,  # Enable blackhole processing
                "watch_folders": {
                    "sonarr": "/mnt/downloads/blackhole/sonarr",
                    "radarr": "/mnt/downloads/blackhole/radarr"
                },
                "check_interval": "30s",  # Interval to check for new files
                "auto_process": True  # Auto process new files
            },
            "api": {
                "enable_cors": True,  # Enable CORS
                "rate_limit": {
                    "enabled": True,
                    "requests_per_minute": 60
                }
            },
            "use_auth": False,  # Enable authentication for WebUI/API
            "log_level": "info",  # Log level (info, debug, warning, error)
            "metrics": {
                "enabled": True,  # Enable metrics endpoint
                "port": 8284,  # Metrics port
                "endpoint": "/metrics"  # Metrics endpoint path
            },
            "notifications": {
                "discord": {
                    "enabled": False,  # Enable Discord notifications
                    "webhook_url": "<YOUR_DISCORD_WEBHOOK_URL>",
                    "events": ["download_complete", "download_failed", "repair_complete"]
                }
            },
            "arr": {
                "radarr": {
                    "api_key": "<YOUR_RADARR_API_KEY>",
                    "url": "http://radarr:7878"
                },
                "sonarr": {
                    "api_key": "<YOUR_SONARR_API_KEY>",
                    "url": "http://sonarr:8989"
                }
            }
        }
        # Save template
        template_file = self.decypharr_config_dir / "config.template.json"
        with open(template_file, 'w', encoding='utf-8') as f:
            json.dump(template, f, indent=2)
        print(f"  ✓ Config template saved to: {template_file}")
#!/usr/bin/env python3

import os
import sys
import json
import time
import requests
from pathlib import Path
from typing import Optional

class DecypharrConfigurator:
    """Main Decypharr configuration class"""
    
    def __init__(self, storage_path: str):
        self.storage_path = self._validate_storage_path(storage_path)
        self.decypharr_config_dir = Path(self.storage_path) / "Decypharr" / "config"
        self.decypharr_downloads_dir = Path(self.storage_path) / "downloads" / "Decypharr"
        self.decypharr_movies_dir = Path(self.storage_path) / "downloads" / "Decypharr" / "movies"
        self.decypharr_tv_dir = Path(self.storage_path) / "downloads" / "Decypharr" / "tv"

        # Container paths for use in config (must match docker-compose volume mappings)
        self.container_downloads = "/mnt/downloads"
        self.container_symlinks = f"{self.container_downloads}/symlinks"
        self.container_temp = f"{self.container_downloads}/temp"
        self.container_completed = f"{self.container_downloads}/completed"

        # Service URLs (using Docker network names)
        self.radarr_url = "http://radarr:7878"
        self.sonarr_url = "http://sonarr:8989"
        self.decypharr_url = "http://decypharr:8282"

        # API Keys from environment
        self.rd_api_key = os.environ.get('RD_API_TOKEN', '')
        self.ad_api_key = os.environ.get('AD_API_TOKEN', '')
        self.dl_api_key = os.environ.get('DEBRID_LINK_API_TOKEN', '')
        self.tb_api_key = os.environ.get('TORBOX_API_TOKEN', '')
        
    def _validate_storage_path(self, path: str) -> str:
        """Validate storage path for security"""
        try:
            path_obj = Path(path).resolve()
            if not path_obj.is_absolute():
                raise ValueError("Storage path must be absolute")
            return str(path_obj)
        except Exception as e:
            print(f"⚠️  Invalid storage path '{path}': {e}")
            raise ValueError(f"Invalid storage path '{path}': {e}")
            
    def ensure_directories(self):
        """Create necessary directories for Decypharr"""
        print("📁 Creating Decypharr directories...")

        qbittorrent_symlinks = self.decypharr_downloads_dir / "symlinks"
        qbittorrent_temp = self.decypharr_downloads_dir / "temp"
        qbittorrent_completed = self.decypharr_downloads_dir / "completed"

        directories = [
            self.decypharr_config_dir,
            self.decypharr_downloads_dir,
            self.decypharr_movies_dir,
            self.decypharr_tv_dir,
            # qBittorrent required folders
            qbittorrent_symlinks,
            qbittorrent_temp,
            qbittorrent_completed,
            # Symlink directories for content organization
            qbittorrent_symlinks / "movies",
            qbittorrent_symlinks / "tv",
            # Blackhole directories
            self.decypharr_downloads_dir / "blackhole" / "sonarr",
            self.decypharr_downloads_dir / "blackhole" / "radarr",
            # Remote mount points (for potential future use)
            Path(self.storage_path) / "mnt" / "remote" / "realdebrid",
            Path(self.storage_path) / "mnt" / "remote" / "alldebrid",
        ]

        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"  ✓ Created: {directory}")
            
    def wait_for_service(self, service_name: str, url: str, max_attempts: int = 30) -> bool:
        """Wait for a service to become available"""
        print(f"⏳ Waiting for {service_name} to be ready...")
        
        for attempt in range(max_attempts):
            try:
                # Try different endpoints based on service
                if "decypharr" in url.lower():
                    response = requests.get(f"{url}/api/v2/app/version", timeout=5)
                elif "radarr" in url.lower() or "sonarr" in url.lower():
                    response = requests.get(f"{url}/api/v3/system/status", timeout=5, headers={'X-Api-Key': 'dummy'})
                else:
                    response = requests.get(f"{url}/ping", timeout=5)
                    
                if response.status_code in [200, 401]:  # 401 means service is up but needs auth
                    print(f"  ✓ {service_name} is ready!")
                    return True
                    
            except requests.exceptions.RequestException:
                pass
            
            if attempt < max_attempts - 1:
                print(f"  ⏳ Attempt {attempt + 1}/{max_attempts}, retrying in 10s...")
                time.sleep(10)
                
        print(f"  ⚠️  {service_name} not responding, continuing anyway...")
        return False
        
    def get_api_key(self, service_name: str, base_url: str, config_path: str, max_wait: int = 120, poll_interval: int = 5) -> Optional[str]:
        """Extract API key from service configuration, waiting up to max_wait seconds if needed"""
        config_file = Path(config_path) / "config.xml"
        waited = 0
        while waited < max_wait:
            try:
                if config_file.exists():
                    with open(config_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                    # Extract API key using basic string parsing
                    if '<ApiKey>' in content and '</ApiKey>' in content:
                        start = content.find('<ApiKey>') + 8
                        end = content.find('</ApiKey>')
                        api_key = content[start:end].strip()
                        if api_key and len(api_key) > 10:
                            print(f"  ✓ Found {service_name} API key after waiting {waited}s")
                            return api_key
                else:
                    print(f"  ⏳ Waiting for {service_name} config.xml to appear...")
            except Exception as e:
                print(f"  ⚠️  Could not read {service_name} API key: {e}")
            time.sleep(poll_interval)
            waited += poll_interval
        print(f"  ⚠️  Timed out waiting for {service_name} API key after {max_wait}s")
        return None
        
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
                
        if services_tested:
            print(f"  ✅ Successfully tested {len(services_tested)} debrid service(s)")
            return True
        else:
            print("  ⚠️  No debrid services could be verified")
            return False
            
    def _replace_storage_path(self, obj):
        """Recursively replace ${STORAGE_PATH} with self.storage_path in all strings in obj"""
        if isinstance(obj, dict):
            return {k: self._replace_storage_path(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [self._replace_storage_path(v) for v in obj]
        elif isinstance(obj, str):
            return obj.replace("${STORAGE_PATH}", self.storage_path)
        else:
            return obj

    def create_decypharr_config(self):
        """Generate Decypharr configuration file with dynamic API keys"""
        print("📝 Generating Decypharr configuration...")

        # Determine which debrid services are available
        debrid_configs = []


        # Helper to build debrid folder path
        def build_debrid_folder(service_name):
            return str(Path(self.storage_path) / "downloads" / "Decypharr" / service_name / "__all__")

        if self.rd_api_key:
            debrid_configs.append({
                "name": "realdebrid",
                "api_key": self.rd_api_key,
                "folder": build_debrid_folder("realdebrid"),
                "use_webdav": True,
                "webdav_url": "https://webdav.real-debrid.com",
                "enabled": True
            })
            print("  ✓ Real-Debrid configuration added")

        if self.ad_api_key:
            debrid_configs.append({
                "name": "alldebrid",
                "api_key": self.ad_api_key,
                "folder": build_debrid_folder("alldebrid"),
                "use_webdav": True,
                "webdav_url": "https://webdav.alldebrid.com",
                "enabled": True
            })
            print("  ✓ AllDebrid configuration added")

        if self.dl_api_key:
            debrid_configs.append({
                "name": "debridlink",
                "api_key": self.dl_api_key,
                "folder": build_debrid_folder("debridlink"),
                "use_webdav": True,
                "enabled": True
            })
            print("  ✓ Debrid-Link configuration added")

        if self.tb_api_key:
            debrid_configs.append({
                "name": "torbox",
                "api_key": self.tb_api_key,
                "folder": build_debrid_folder("torbox"),
                "use_webdav": True,
                "enabled": True
            })
            print("  ✓ Torbox configuration added")

        if not debrid_configs:
            print("  ⚠️  No debrid API keys found in environment!")
            print("  💡 Please set RD_API_TOKEN, AD_API_TOKEN, DEBRID_LINK_API_TOKEN, or TORBOX_API_TOKEN")
            print("  📝 Creating basic configuration without debrid services...")

        # Dynamically get Radarr and Sonarr API keys
        radarr_api_key = self.get_api_key("Radarr", self.radarr_url, f"{self.storage_path}/Radarr/config")
        sonarr_api_key = self.get_api_key("Sonarr", self.sonarr_url, f"{self.storage_path}/Sonarr/config")


        # Dynamically grab Discord webhook URL (existing logic)
        discord_webhook_url = None
        import os
        # Fix: Use Surge project root for .env
        project_root = Path(os.path.abspath(os.path.dirname(__file__))).parent
        env_path = project_root / ".env"
        if env_path.exists():
            with open(env_path, 'r', encoding='utf-8') as env_file:
                for line in env_file:
                    if line.strip().startswith("DISCORD_WEBHOOK_URL="):
                        discord_webhook_url = line.strip().split("=", 1)[1]
                        discord_webhook_url = discord_webhook_url.strip().strip('"').strip("'")
                        break
        if not discord_webhook_url or not discord_webhook_url.strip():
            discord_webhook_url = os.environ.get('DISCORD_WEBHOOK_URL', None)
        if not discord_webhook_url or not discord_webhook_url.strip():
            webhook_file = Path(self.storage_path) / "discord_webhook.txt"
            if webhook_file.exists():
                with open(webhook_file, 'r', encoding='utf-8') as wf:
                    discord_webhook_url = wf.read().strip()
        if not discord_webhook_url or not discord_webhook_url.strip():
            discord_webhook_url = "<YOUR_DISCORD_WEBHOOK_URL>"

        # --- ARR SECTION UPDATE ---
        arrs = []
        # Sonarr
        arrs.append({
            "name": "sonarr",
            "host": self.sonarr_url,
            "token": sonarr_api_key if sonarr_api_key else "SONARR_API_KEY_PLACEHOLDER",
            "cleanup": True,
            "download_unacached": False,
            "source": "auto"
        })
        # Radarr
        arrs.append({
            "name": "radarr",
            "host": self.radarr_url,
            "token": radarr_api_key if radarr_api_key else "RADARR_API_KEY_PLACEHOLDER",
            "cleanup": True,
            "download_unacached": False,
            "source": "auto"
        })

        qbittorrent_download_folder = str(Path(self.storage_path) / "downloads" / "Decypharr" / "symlinks")
        qbittorrent_temp_folder = str(Path(self.storage_path) / "downloads" / "Decypharr" / "temp")
        qbittorrent_completed_folder = str(Path(self.storage_path) / "downloads" / "Decypharr" / "completed")

        rclone_mount_path = str(Path(self.storage_path) / "downloads" / "Decypharr" / "rclone" / "remote")
        rclone_cache_dir = str(Path(self.storage_path) / "downloads" / "Decypharr" / "rclone" / "cache")

        config = {
            "version": "1.0",
            "debrids": debrid_configs,
            "qbittorrent": {
                "port": "8282",
                "download_folder": qbittorrent_download_folder,
                "categories": ["sonarr", "radarr", "lidarr", "readarr"],
                "default_category": "default",
                "temp_folder": qbittorrent_temp_folder,
                "completed_folder": qbittorrent_completed_folder
            },
            "rclone": {
                "enabled": True,
                "mount_path": rclone_mount_path,
                "cache_dir": rclone_cache_dir,
                "vfs_cache_mode": "full",
                "vfs_cache_max_age": "1000h",
                "vfs_cache_max_size": "10G",
                "vfs_cache_poll_interval": "1m",
                "vfs_read_chunk_size": "10M",
                "vfs_read_chunk_size_limit": "off",
                "vfs_read_ahead": "0",
                "buffer_size": "10M",
                "uid": 1000,
                "gid": 1000,
                "attr_timeout": "10y",
                "dir_cache_time": "5m",
                "no_modtime": True,
                "no_checksum": True
            },
            "rclone": {
                "enabled": True,
                "mount_path": rclone_mount_path,
                "cache_dir": rclone_cache_dir,
                "vfs_cache_mode": "full",
                "vfs_cache_max_age": "1000h",
                "vfs_cache_max_size": "10G",
                "vfs_cache_poll_interval": "1m",
                "vfs_read_chunk_size": "10M",
                "vfs_read_chunk_size_limit": "off",
                "vfs_read_ahead": "0",
                "buffer_size": "10M",
                "uid": 1000,
                "gid": 1000,
                "attr_timeout": "10y",
                "dir_cache_time": "5m",
                "no_modtime": True,
                "no_checksum": True
            },
            "repair": {
                "enabled": True,
                "interval": "6h",
                "check_symlinks": True,
                "check_missing_files": True,
                "auto_repair": True,
                "max_retries": 3
            },
            "webdav": {
                "enabled": True,
                "port": 8283,
                "prefix": "/webdav",
                "auto_mount": True
            },
            "blackhole": {
                "enabled": True,
                "watch_folders": {
                    "sonarr": str(Path(self.storage_path) / "downloads" / "blackhole" / "sonarr"),
                    "radarr": str(Path(self.storage_path) / "downloads" / "blackhole" / "radarr")
                },
                "check_interval": "30s",
                "auto_process": True
            },
            "api": {
                "enable_cors": True,
                "rate_limit": {
                    "enabled": True,
                    "requests_per_minute": 60
                }
            },
            "use_auth": False,
            "log_level": os.environ.get('DECYPHARR_LOG_LEVEL', 'info'),
            "metrics": {
                "enabled": True,
                "port": 8284,
                "endpoint": "/metrics"
            },
            "notifications": {
                "discord": {
                    "enabled": bool(discord_webhook_url and discord_webhook_url != "<YOUR_DISCORD_WEBHOOK_URL>"),
                    "webhook_url": discord_webhook_url,
                    "events": ["download_complete", "download_failed", "repair_complete"]
                }
            },
            "arrs": arrs
        }

        # Save configuration
        config_file = self.decypharr_config_dir / "config.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)

        print(f"  ✓ Configuration saved to: {config_file}")
        print(f"  ✓ Configured {len(debrid_configs)} debrid service(s)")
        if radarr_api_key:
            print(f"  ✓ Radarr API key injected: {radarr_api_key}")
        else:
            print("  ⚠️  Radarr API key not found, using placeholder")
        if sonarr_api_key:
            print(f"  ✓ Sonarr API key injected: {sonarr_api_key}")
        else:
            print("  ⚠️  Sonarr API key not found, using placeholder")

        # Dynamically create all Decypharr config folders with sudo mkdir
        import subprocess
        folders_to_create = set()
        # Add all folder paths from config
        folders_to_create.add(str(self.decypharr_config_dir))
        folders_to_create.add(str(self.decypharr_downloads_dir))
        folders_to_create.add(str(self.decypharr_movies_dir))
        folders_to_create.add(str(self.decypharr_tv_dir))
        folders_to_create.add(qbittorrent_download_folder)
        folders_to_create.add(qbittorrent_temp_folder)
        folders_to_create.add(qbittorrent_completed_folder)
        folders_to_create.add(rclone_mount_path)
        folders_to_create.add(rclone_cache_dir)
        folders_to_create.add(str(Path(self.storage_path) / "downloads" / "Decypharr" / "blackhole" / "sonarr"))
        folders_to_create.add(str(Path(self.storage_path) / "downloads" / "Decypharr" / "blackhole" / "radarr"))
        # Add debrid folders
        for debrid in debrid_configs:
            folders_to_create.add(debrid.get("folder"))
        # Create each folder with sudo mkdir -p
        for folder in folders_to_create:
            if folder and not Path(folder).exists():
                try:
                    print(f"  🛠️  Creating folder: {folder}")
                    subprocess.run(["sudo", "mkdir", "-p", folder], check=True)
                except Exception as e:
                    print(f"  ⚠️  Could not create folder {folder}: {e}")
        return True
        
    def configure_arr_download_client(self, service_name: str, service_url: str, api_key: str):
        """Configure Decypharr as download client in Radarr/Sonarr"""
        print(f"🔗 Configuring {service_name} download client...")
        
        if not api_key:
            print(f"  ⚠️  No API key available for {service_name}")
            return False
            
        try:
            headers = {"X-Api-Key": api_key, "Content-Type": "application/json"}
            
            # Check if Decypharr client already exists
            response = requests.get(f"{service_url}/api/v3/downloadclient", headers=headers, timeout=10)
            if response.status_code == 200:
                existing_clients = response.json()
                for client in existing_clients:
                    if client.get('name') == 'Decypharr':
                        print(f"  ✓ Decypharr download client already configured in {service_name}")
                        return True
                        
            # Create Decypharr download client configuration
            download_client_config = {
                "enable": True,
                "name": "Decypharr",
                "implementation": "QBittorrent",  # Decypharr provides qBittorrent API
                "configContract": "QBittorrentSettings",
                "priority": 1,  # Higher priority than other clients
                "removeCompletedDownloads": True,
                "removeFailedDownloads": True,
                "fields": [
                    {
                        "name": "host",
                        "value": "decypharr"  # Docker service name
                    },
                    {
                        "name": "port",
                        "value": 8282
                    },
                    {
                        "name": "urlBase", 
                        "value": ""
                    },
                    {
                        "name": "username",
                        "value": ""  # No auth by default
                    },
                    {
                        "name": "password",
                        "value": ""  # No auth by default
                    },
                    {
                        "name": "category",
                        "value": service_name.lower()  # sonarr or radarr
                    },
                    {
                        "name": "priority",
                        "value": 0  # Normal priority
                    },
                    {
                        "name": "initialState",
                        "value": 0  # Start downloads immediately
                    },
                    {
                        "name": "sequentialOrder",
                        "value": False
                    },
                    {
                        "name": "firstAndLast",
                        "value": False
                    }
                ],
                "tags": ["debrid", "decypharr", "primary"]
            }
            
            response = requests.post(
                f"{service_url}/api/v3/downloadclient",
                headers=headers,
                json=download_client_config,
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                print(f"  ✓ Decypharr download client configured in {service_name}")
                return True
            else:
                print(f"  ⚠️  Failed to configure download client in {service_name}: {response.status_code}")
                # Don't print full response as it might contain sensitive data
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"  ⚠️  Error configuring {service_name}: {type(e).__name__}")
            return False
        except Exception as e:
            print(f"  ⚠️  Unexpected error configuring {service_name}: {type(e).__name__}")
            return False
            
    def create_helper_scripts(self):
        """Create helper scripts for Decypharr management"""
        print("📝 Creating helper scripts...")
        
        # Create status checking script
        status_script = self.decypharr_config_dir / "check_status.py"
        status_content = '''#!/usr/bin/env python3
"""Decypharr Status Checker"""

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
        
    # Check Decypharr service
    try:
        qbt_port = config.get('qbittorrent', {}).get('port', '8282')
        response = requests.get(f"http://localhost:{qbt_port}/api/v2/app/version", timeout=5)
        if response.status_code == 200:
            version = response.text.strip().replace('"', '')
            print(f"✅ Decypharr service is running (qBittorrent API v{version})")
        else:
            print("⚠️  Decypharr service not responding")
    except Exception as e:
        print(f"❌ Decypharr service error: {e}")
        
    # Check debrid services
    debrid_count = 0
    for debrid in config.get('debrids', []):
        if debrid.get('enabled'):
            debrid_count += 1
            print(f"✅ {debrid['name']}: Configured and enabled")
        else:
            print(f"⚠️  {debrid['name']}: Configured but disabled")
            
    print(f"📊 Total debrid services: {debrid_count}")
    
    # Check directories
    directories = [
        "/mnt/downloads/symlinks",
        "/mnt/downloads/blackhole/sonarr",
        "/mnt/downloads/blackhole/radarr"
    ]
    
    for directory in directories:
        if Path(directory).exists():
            file_count = len(list(Path(directory).rglob("*")))
            print(f"📁 {directory}: {file_count} items")
        else:
            print(f"⚠️  {directory}: Not found")
            
    return True

if __name__ == "__main__":
    check_status()
'''
        
        with open(status_script, 'w', encoding='utf-8') as f:
            f.write(status_content)
            
        # Make script executable with secure permissions
        os.chmod(status_script, 0o750)
        print(f"  ✓ Created status script: {status_script}")
        
        # Create repair script
        repair_script = self.decypharr_config_dir / "repair_links.py"
        repair_content = '''#!/usr/bin/env python3
"""Decypharr Repair Links Script"""

import json
import os
import requests
from pathlib import Path

def repair_symlinks():
    config_file = Path("/app/config/config.json")
    if not config_file.exists():
        print("❌ Configuration file not found")
        return False
        
    with open(config_file, 'r') as f:
        config = json.load(f)
        
    # Trigger repair via Decypharr API (if available)
    try:
        qbt_port = config.get('qbittorrent', {}).get('port', '8282')
        response = requests.post(f"http://localhost:{qbt_port}/api/decypharr/repair", timeout=30)
        if response.status_code == 200:
            print("✅ Repair process triggered successfully")
            return True
        else:
            print(f"⚠️  Repair trigger failed: {response.status_code}")
    except Exception as e:
        print(f"⚠️  Could not trigger repair via API: {e}")
    
    # Manual symlink check
    symlink_dir = Path("/mnt/downloads/symlinks")
    if symlink_dir.exists():
        broken_links = []
        for item in symlink_dir.rglob("*"):
            if item.is_symlink() and not item.exists():
                broken_links.append(item)
                
        if broken_links:
            print(f"🔍 Found {len(broken_links)} broken symlinks")
            for link in broken_links[:10]:  # Show first 10
                print(f"  ❌ {link}")
            if len(broken_links) > 10:
                print(f"  ... and {len(broken_links) - 10} more")
        else:
            print("✅ No broken symlinks found")
    
    return True

if __name__ == "__main__":
    repair_symlinks()
'''
        
        with open(repair_script, 'w', encoding='utf-8') as f:
            f.write(repair_content)
            
        os.chmod(repair_script, 0o750)
        print(f"  ✓ Created repair script: {repair_script}")
        
        return True
        
    def run_configuration(self):
        """Main configuration process"""
        print("🚀 Starting Decypharr configuration...")
        print(f"   Storage path: {self.storage_path}")
        print(f"   Config directory: {self.decypharr_config_dir}")
        
        success_count = 0
        total_steps = 6
        
        # Step 1: Create directories
        try:
            self.ensure_directories()
            success_count += 1
            print("✅ Step 1/6: Directory structure created")
        except Exception as e:
            print(f"❌ Step 1/6 failed: {e}")
            
        # Step 1b: Generate config template
        try:
            self.generate_config_template()
            print("✅ Step 1b: Config template generated")
        except Exception as e:
            print(f"❌ Step 1b failed: {e}")
        # Step 2: Test debrid services
        try:
            if self.test_debrid_services():
                success_count += 1
                print("✅ Step 2/6: Debrid services tested")
            else:
                print("⚠️  Step 2/6: Some debrid services failed")
        except Exception as e:
            print(f"❌ Step 2/6 failed: {e}")
            
        # Step 3: Create Decypharr configuration
        try:
            if self.create_decypharr_config():
                success_count += 1
                print("✅ Step 3/6: Decypharr configuration created")
            else:
                print("⚠️  Step 3/6: Configuration created with warnings")
        except Exception as e:
            print(f"❌ Step 3/6 failed: {e}")
            
        # Step 4: Get API keys from *arr services
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
            
        # Step 6: Create helper scripts
        try:
            self.create_helper_scripts()
            success_count += 1
            print("✅ Step 6/6: Helper scripts created")
        except Exception as e:
            print(f"❌ Step 6/6 failed: {e}")
            
        # Final summary
        print(f"\n🎯 Decypharr configuration completed!")
        print(f"   ✅ {success_count}/{total_steps} steps successful")
        
        if success_count >= 4:
            print("✅ Decypharr is ready for use!")
            print("\n📋 Next steps:")
            print("   1. Access Decypharr web interface at: http://localhost:8282")
            print("   2. Verify debrid service connections")
            print("   3. Test download functionality with *arr services")
            print("   4. Monitor repair worker for symlink management")
            print("   5. Check logs: docker logs surge-decypharr")
            
            # Show configuration summary
            print(f"\n📁 Configuration files:")
            print(f"   • Main config: {self.decypharr_config_dir}/config.json")
            print(f"   • Status script: {self.decypharr_config_dir}/check_status.py")
            print(f"   • Repair script: {self.decypharr_config_dir}/repair_links.py")
            
            return True
        else:
            print("⚠️  Decypharr configuration completed with issues")
            print("💡 Check the output above for specific problems")
            return False

def main():
    """Main entry point"""
    if len(sys.argv) < 2 or not sys.argv[1].strip():
        print("❌ ERROR: STORAGE_PATH argument is required.\nUsage: python3 configure-decypharr.py <STORAGE_PATH>")
        sys.exit(1)
    storage_path = sys.argv[1]

    print("=" * 60)
    print("🔧 DECYPHARR AUTOMATED CONFIGURATION")
    print("=" * 60)

    configurator = DecypharrConfigurator(storage_path)
    success = configurator.run_configuration()

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()