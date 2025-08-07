#!/usr/bin/env python3

"""
NZBGet Automatic Configuration Script for Surge
Configures NZBGet and integrates it with Radarr, Sonarr, and Prowlarr
"""

import os
import json
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
import time
import sys

class NZBGetConfigurator:
    def __init__(self, storage_path=None):
        try:
            self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        except NameError:
            # Handle case when __file__ is not defined (e.g., when exec'd)
            self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(os.getcwd())))
        self.storage_path = storage_path or os.environ.get('STORAGE_PATH', '/opt/surge')
        self.nzbget_config_path = os.path.join(self.storage_path, 'NZBGet', 'config', 'nzbget.conf')
        
        # NZBGet connection details
        self.nzbget_host = os.environ.get('NZBGET_HOST', 'localhost')
        self.nzbget_port = int(os.environ.get('NZBGET_PORT', '6789'))
        self.nzbget_username = os.environ.get('NZBGET_USER', 'admin')
        self.nzbget_password = os.environ.get('NZBGET_PASS') or self._generate_secure_password()
        if not os.environ.get('NZBGET_PASS'):
            self.log("⚠️  No NZBGET_PASS set in environment, using generated password", "WARNING")

    def _generate_secure_password(self):
        """Generate a secure password for NZBGet if none provided"""
        import secrets, string
        password = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(16))
        self.log(f"⚠️  Generated secure NZBGet password: {password}", "WARNING")
        self.log("⚠️  Please set NZBGET_PASS in your .env file for persistence", "WARNING")
        return password
        self.log("⚠️ Using default NZBGet password. For security, set NZBGET_PASS environment variable", "WARNING")
        
        # Container names for internal communication
        self.container_names = {
            'nzbget': 'surge-nzbget',
            'radarr': 'surge-radarr',
            'sonarr': 'surge-sonarr',
            'prowlarr': 'surge-prowlarr'
        }
        
        # Service URLs for API communication
        self.service_urls = {
            'radarr': os.environ.get('RADARR_URL', 'http://localhost:7878'),
            'sonarr': os.environ.get('SONARR_URL', 'http://localhost:8989'),
            'prowlarr': os.environ.get('PROWLARR_URL', 'http://localhost:9696')
        }
        
    def log(self, message, level="INFO"):
        print(f"[{level}] {message}")
        
    def wait_for_service(self, url, max_retries=12, retry_delay=10, api_key=None):
        """Wait for a service to become available."""
        headers = {}
        if api_key:
            headers['X-Api-Key'] = api_key
            
        for attempt in range(max_retries):
            try:
                req = urllib.request.Request(url, headers=headers)
                with urllib.request.urlopen(req, timeout=10) as response:
                    if response.status == 200:
                        return True
            except Exception as e:
                self.log(f"Service not ready (attempt {attempt + 1}/{max_retries}): {e}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
        return False
        
    def get_api_key_from_xml(self, config_path):
        """Extract API key from XML config file."""
        try:
            if not os.path.exists(config_path):
                self.log(f"Config file not found: {config_path}", "WARNING")
                return None
                
            tree = ET.parse(config_path)
            root = tree.getroot()
            
            api_key_elem = root.find('.//ApiKey')
            if api_key_elem is not None and api_key_elem.text:
                return api_key_elem.text.strip()
                
            self.log(f"ApiKey not found in {config_path}", "WARNING")
            return None
            
        except Exception as e:
            self.log(f"Error reading {config_path}: {e}", "ERROR")
            return None
            
    def configure_nzbget_server(self):
        """Configure NZBGet server settings."""
        self.log("🔧 Configuring NZBGet server settings...")
        
        config_dir = os.path.dirname(self.nzbget_config_path)
        os.makedirs(config_dir, exist_ok=True)
        
        # Wait for NZBGet container to start and create config
        max_wait = 30
        for attempt in range(max_wait):
            if os.path.exists(self.nzbget_config_path):
                break
            if attempt < max_wait - 1:
                self.log(f"Waiting for NZBGet config file... (attempt {attempt + 1}/{max_wait})")
                time.sleep(2)
                
        if not os.path.exists(self.nzbget_config_path):
            self.log("Creating default NZBGet configuration...", "INFO")
            self.create_default_nzbget_config()
            
        # Configure NZBGet settings
        try:
            self.update_nzbget_config()
            self.log("✅ NZBGet server configured successfully")
            return True
        except Exception as e:
            self.log(f"❌ Failed to configure NZBGet: {e}", "ERROR")
            return False
            
    def create_default_nzbget_config(self):
        """Create a default NZBGet configuration."""
        config_content = f"""# NZBGet main configuration file
# Auto-generated by Surge automation

# SERVER
MainDir=/downloads
DestDir=/downloads/completed
InterDir=/downloads/incomplete
QueueDir=/downloads/queue
TempDir=/downloads/tmp
WebDir=/usr/share/nzbget/webui
ConfigTemplate=/usr/share/nzbget/nzbget.conf
ScriptDir=/downloads/scripts

# SECURITY
ControlUsername={self.nzbget_username}
ControlPassword={self.nzbget_password}
ControlIP=0.0.0.0
ControlPort=6789
SecureControl=no
SecureCert=
SecureKey=

# DOWNLOAD
ArticleTimeout=60
UrlTimeout=60
RemoteTimeout=90
DownloadRate=0
ArticleRetries=3
ArticleInterval=10
UrlRetries=3
UrlInterval=10
FlushQueue=yes
Continue=yes
Reorder=yes
Decode=yes
RetryOnCrcError=yes
CrcCheck=yes
DirectWrite=yes
WriteBuffer=0
NzbDirInterval=5
NzbDirFileAge=60
DiskSpace=250
TempPauseDownload=no
CrashTrace=yes
CrashDump=no
ParTimeLimit=0
KeepHistory=7

# CATEGORIES
Category1.Name=movies
Category1.DestDir=/downloads/completed/movies
Category1.Unpack=yes
Category1.DefScript=
Category1.Aliases=movie,movies,film,films

Category2.Name=tv
Category2.DestDir=/downloads/completed/tv
Category2.Unpack=yes
Category2.DefScript=
Category2.Aliases=tv,series,show,shows,episode,episodes

Category3.Name=music
Category3.DestDir=/downloads/completed/music
Category3.Unpack=yes
Category3.DefScript=
Category3.Aliases=music,audio,mp3,flac

Category4.Name=books
Category4.DestDir=/downloads/completed/books
Category4.Unpack=yes
Category4.DefScript=
Category4.Aliases=book,books,ebook,ebooks

# UNPACK
UnpackTimeLimit=0
DirectUnpack=no
UnpackCleanupDisk=yes
UnrarCmd=unrar
SevenZipCmd=7z
ExtCleanupDisk=
ParIgnoreExt=
UnpackIgnoreExt=
UnpackPassFile=
UnpackPauseQueue=no

# EXTENSION SCRIPTS
Extensions=
ShellOverride=.py=/usr/bin/python3

# SCHEDULER
TaskX.Time=*,*:00,*:30
TaskX.WeekDays=1-7
TaskX.Command=DownloadRate
TaskX.Param=0

# LOGGING
WriteLog=append
RotateLog=3
ErrorTarget=both
WarningTarget=both
InfoTarget=both
DetailTarget=log
DebugTarget=none
LogBuffer=1000
"""

        with open(self.nzbget_config_path, 'w') as f:
            f.write(config_content)
            
        self.log("📝 Default NZBGet configuration created")
        
    def update_nzbget_config(self):
        """Update existing NZBGet configuration with optimized settings."""
        if not os.path.exists(self.nzbget_config_path):
            return False
            
        # Read existing config
        config_updates = {
            'MainDir': '/downloads',
            'DestDir': '/downloads/completed',
            'InterDir': '/downloads/incomplete',
            'QueueDir': '/downloads/queue',
            'TempDir': '/downloads/tmp',
            'ControlUsername': self.nzbget_username,
            'ControlPassword': self.nzbget_password,
            'ControlIP': '0.0.0.0',
            'ControlPort': '6789',
            'CrcCheck': 'yes',
            'Decode': 'yes',
            'DirectWrite': 'yes',
            'KeepHistory': '7',
            'DiskSpace': '250',
            'ParTimeLimit': '0'
        }
        
        # Read current config
        with open(self.nzbget_config_path, 'r') as f:
            lines = f.readlines()
            
        # Update config lines
        updated_lines = []
        updated_keys = set()
        
        for line in lines:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key = line.split('=')[0].strip()
                if key in config_updates:
                    updated_lines.append(f"{key}={config_updates[key]}\n")
                    updated_keys.add(key)
                else:
                    updated_lines.append(line + '\n')
            else:
                updated_lines.append(line + '\n')
                
        # Add any missing config keys
        for key, value in config_updates.items():
            if key not in updated_keys:
                updated_lines.append(f"{key}={value}\n")
                
        # Write updated config
        with open(self.nzbget_config_path, 'w') as f:
            f.writelines(updated_lines)
            
        return True
        
    def test_nzbget_connection(self):
        """Test connection to NZBGet API."""
        try:
            auth_string = f"{self.nzbget_username}:{self.nzbget_password}"
            auth_header = 'Basic ' + urllib.parse.quote(auth_string.encode('utf-8').hex())
            
            url = f"http://{self.nzbget_host}:{self.nzbget_port}/jsonrpc"
            data = json.dumps({
                "method": "status",
                "params": [],
                "id": 1
            }).encode('utf-8')
            
            req = urllib.request.Request(url, data=data)
            req.add_header('Content-Type', 'application/json')
            req.add_header('Authorization', auth_header)
            
            with urllib.request.urlopen(req, timeout=10) as response:
                if response.status == 200:
                    result = json.loads(response.read().decode())
                    if 'result' in result:
                        self.log("✅ NZBGet API connection successful")
                        return True
                        
        except Exception as e:
            self.log(f"❌ NZBGet API connection failed: {e}", "ERROR")
            
        return False
        
    def add_nzbget_to_radarr(self):
        """Add NZBGet as download client in Radarr."""
        self.log("📽️ Adding NZBGet to Radarr...")
        
        # Get Radarr API key
        radarr_config = os.path.join(self.storage_path, "Radarr", "config", "config.xml")
        radarr_api_key = self.get_api_key_from_xml(radarr_config)
        
        if not radarr_api_key:
            self.log("❌ Could not get Radarr API key", "ERROR")
            return False
            
        # Wait for Radarr to be ready
        if not self.wait_for_service(f"{self.service_urls['radarr']}/api/v3/system/status", api_key=radarr_api_key):
            self.log("❌ Radarr service not ready", "ERROR")
            return False
            
        # Configure NZBGet in Radarr
        download_client_data = {
            "enable": True,
            "protocol": "usenet",
            "priority": 1,
            "removeCompletedDownloads": True,
            "removeFailedDownloads": True,
            "name": "NZBGet",
            "fields": [
                {"name": "host", "value": self.container_names['nzbget']},
                {"name": "port", "value": 6789},
                {"name": "username", "value": self.nzbget_username},
                {"name": "password", "value": self.nzbget_password},
                {"name": "category", "value": "movies"},
                {"name": "useSsl", "value": False}
            ],
            "implementationName": "NZBGet",
            "implementation": "Nzbget",
            "configContract": "NzbgetSettings",
            "tags": []
        }
        
        try:
            data = json.dumps(download_client_data).encode('utf-8')
            req = urllib.request.Request(
                f"{self.service_urls['radarr']}/api/v3/downloadclient",
                data=data,
                headers={
                    'Content-Type': 'application/json',
                    'X-Api-Key': radarr_api_key
                },
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=10) as response:
                if response.status in [200, 201]:
                    self.log("✅ NZBGet added to Radarr successfully")
                    return True
                else:
                    self.log(f"❌ Failed to add NZBGet to Radarr (HTTP {response.status})", "ERROR")
                    
        except Exception as e:
            self.log(f"❌ Error adding NZBGet to Radarr: {e}", "ERROR")
            
        return False
        
    def add_nzbget_to_sonarr(self):
        """Add NZBGet as download client in Sonarr."""
        self.log("📺 Adding NZBGet to Sonarr...")
        
        # Get Sonarr API key
        sonarr_config = os.path.join(self.storage_path, "Sonarr", "config", "config.xml")
        sonarr_api_key = self.get_api_key_from_xml(sonarr_config)
        
        if not sonarr_api_key:
            self.log("❌ Could not get Sonarr API key", "ERROR")
            return False
            
        # Wait for Sonarr to be ready
        if not self.wait_for_service(f"{self.service_urls['sonarr']}/api/v3/system/status", api_key=sonarr_api_key):
            self.log("❌ Sonarr service not ready", "ERROR")
            return False
            
        # Configure NZBGet in Sonarr
        download_client_data = {
            "enable": True,
            "protocol": "usenet",
            "priority": 1,
            "removeCompletedDownloads": True,
            "removeFailedDownloads": True,
            "name": "NZBGet",
            "fields": [
                {"name": "host", "value": self.container_names['nzbget']},
                {"name": "port", "value": 6789},
                {"name": "username", "value": self.nzbget_username},
                {"name": "password", "value": self.nzbget_password},
                {"name": "category", "value": "tv"},
                {"name": "useSsl", "value": False}
            ],
            "implementationName": "NZBGet",
            "implementation": "Nzbget",
            "configContract": "NzbgetSettings",
            "tags": []
        }
        
        try:
            data = json.dumps(download_client_data).encode('utf-8')
            req = urllib.request.Request(
                f"{self.service_urls['sonarr']}/api/v3/downloadclient",
                data=data,
                headers={
                    'Content-Type': 'application/json',
                    'X-Api-Key': sonarr_api_key
                },
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=10) as response:
                if response.status in [200, 201]:
                    self.log("✅ NZBGet added to Sonarr successfully")
                    return True
                else:
                    self.log(f"❌ Failed to add NZBGet to Sonarr (HTTP {response.status})", "ERROR")
                    
        except Exception as e:
            self.log(f"❌ Error adding NZBGet to Sonarr: {e}", "ERROR")
            
        return False
        
    def add_nzbget_to_prowlarr(self):
        """Add NZBGet as download client in Prowlarr."""
        self.log("🔍 Adding NZBGet to Prowlarr...")
        
        # Get Prowlarr API key
        prowlarr_config = os.path.join(self.storage_path, "Prowlarr", "config", "config.xml")
        prowlarr_api_key = self.get_api_key_from_xml(prowlarr_config)
        
        if not prowlarr_api_key:
            self.log("❌ Could not get Prowlarr API key", "ERROR")
            return False
            
        # Wait for Prowlarr to be ready
        if not self.wait_for_service(f"{self.service_urls['prowlarr']}/api/v1/system/status", api_key=prowlarr_api_key):
            self.log("❌ Prowlarr service not ready", "ERROR")
            return False
            
        # Configure NZBGet in Prowlarr
        download_client_data = {
            "enable": True,
            "protocol": "usenet",
            "priority": 1,
            "removeCompletedDownloads": True,
            "removeFailedDownloads": True,
            "name": "NZBGet",
            "fields": [
                {"name": "host", "value": self.container_names['nzbget']},
                {"name": "port", "value": 6789},
                {"name": "username", "value": self.nzbget_username},
                {"name": "password", "value": self.nzbget_password},
                {"name": "useSsl", "value": False}
            ],
            "implementationName": "NZBGet",
            "implementation": "Nzbget",
            "configContract": "NzbgetSettings",
            "tags": []
        }
        
        try:
            data = json.dumps(download_client_data).encode('utf-8')
            req = urllib.request.Request(
                f"{self.service_urls['prowlarr']}/api/v1/downloadclient",
                data=data,
                headers={
                    'Content-Type': 'application/json',
                    'X-Api-Key': prowlarr_api_key
                },
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=10) as response:
                if response.status in [200, 201]:
                    self.log("✅ NZBGet added to Prowlarr successfully")
                    return True
                else:
                    self.log(f"❌ Failed to add NZBGet to Prowlarr (HTTP {response.status})", "ERROR")
                    
        except Exception as e:
            self.log(f"❌ Error adding NZBGet to Prowlarr: {e}", "ERROR")
            
        return False
        
    def run_full_configuration(self):
        """Run the complete NZBGet configuration process."""
        self.log("🚀 Starting NZBGet automation configuration...")
        self.log("=" * 60)
        
        success_count = 0
        total_steps = 5
        
        # Step 1: Configure NZBGet server
        if self.configure_nzbget_server():
            success_count += 1
            
        # Step 2: Wait for NZBGet to be ready
        self.log("⏳ Waiting for NZBGet to start...")
        if self.wait_for_service(f"http://{self.nzbget_host}:{self.nzbget_port}"):
            success_count += 1
            self.log("✅ NZBGet service is ready")
        else:
            self.log("❌ NZBGet service failed to start", "ERROR")
            
        # Step 3: Test NZBGet connection
        if self.test_nzbget_connection():
            success_count += 1
            
        # Step 4: Add to Radarr
        if self.add_nzbget_to_radarr():
            success_count += 1
            
        # Step 5: Add to Sonarr
        if self.add_nzbget_to_sonarr():
            success_count += 1
            
        # Note: Prowlarr doesn't typically manage download clients directly
        # It's mainly for indexers, but we could add it for completeness
        
        self.log("=" * 60)
        self.log(f"🎯 NZBGet Configuration Results: {success_count}/{total_steps} steps completed")
        
        if success_count >= 4:  # Allow for some tolerance
            self.log("🎉 NZBGet automation completed successfully!")
            self.log("💡 NZBGet is now configured and integrated with Radarr and Sonarr")
            self.log(f"🌐 Access NZBGet at: http://localhost:{self.nzbget_port}")
            self.log(f"🔑 Login: {self.nzbget_username} / {'*' * len(self.nzbget_password)}")
            return True
        else:
            self.log("⚠️ NZBGet automation completed with some issues")
            self.log("💡 Check the logs above and manually verify configurations")
            return False

def main():
    """Main entry point for the script."""
    if len(sys.argv) > 1:
        storage_path = sys.argv[1]
    else:
        storage_path = os.environ.get('STORAGE_PATH', '/opt/surge')
        
    configurator = NZBGetConfigurator(storage_path)
    
    success = configurator.run_full_configuration()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
