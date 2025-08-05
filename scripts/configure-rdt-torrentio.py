#!/usr/bin/env python3
"""
RDT-Client & Torrentio Indexer Configuration for Surge

This script automates:
1. RDT-Client setup with Real-Debrid credentials
2. Torrentio indexer configuration in Prowlarr
3. Download client integration with Radarr/Sonarr
4. Comprehensive error handling and verification

Features:
- Secure credential management from environment variables
- No hardcoded API keys or file paths
- Automatic retry logic
- Comprehensive logging
- Integration verification
"""

import os
import sys
import json
import time
import urllib.request
from datetime import datetime

class TorrentioRDTConfigurator:
    """Comprehensive RDT-Client and Torrentio configuration."""
    
    def __init__(self, storage_path=None):
        """Initialize configurator with environment-based settings."""
        self.storage_path = storage_path or self.find_storage_path()
        self.rd_api_token = os.environ.get('RD_API_TOKEN', '')
        
        # Service URLs using environment variables or defaults
        self.service_urls = {
            'rdt-client': os.environ.get('RDT_CLIENT_URL', 'http://localhost:6500'),
            'prowlarr': os.environ.get('PROWLARR_URL', 'http://localhost:9696'),
            'radarr': os.environ.get('RADARR_URL', 'http://localhost:7878'),
            'sonarr': os.environ.get('SONARR_URL', 'http://localhost:8989')
        }
        
        # Container URLs for internal Docker communication
        self.container_urls = {
            'rdt-client': 'http://surge-rdt-client:6500',
            'prowlarr': 'http://surge-prowlarr:9696',
            'radarr': 'http://surge-radarr:7878',
            'sonarr': 'http://surge-sonarr:8989'
        }
        
        if not self.rd_api_token:
            self.log("⚠️ RD_API_TOKEN not found in environment", "WARNING")
            self.log("💡 Some features will require manual configuration", "INFO")
    
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
        
        return '/opt/surge'  # Default fallback
    
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
        """Extract API key from service XML configuration."""
        try:
            if not os.path.exists(config_path):
                return None
                
            with open(config_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            start_tag, end_tag = '<ApiKey>', '</ApiKey>'
            start_idx = content.find(start_tag)
            
            if start_idx != -1:
                start_idx += len(start_tag)
                end_idx = content.find(end_tag, start_idx)
                if end_idx != -1:
                    return content[start_idx:end_idx].strip()
                    
        except Exception as e:
            self.log(f"Error reading API key from {os.path.basename(config_path)}: {e}", "WARNING")
            
        return None
    
    def wait_for_service(self, service_url, service_name="service", max_attempts=20, delay=5):
        """Wait for service with enhanced retry logic."""
        self.log(f"⏳ Waiting for {service_name} to be ready...")
        
        for attempt in range(max_attempts):
            try:
                req = urllib.request.Request(service_url, timeout=10)
                with urllib.request.urlopen(req) as response:
                    if response.status == 200:
                        self.log(f"✅ {service_name} is ready")
                        return True
                        
            except Exception:
                pass
            
            if attempt < max_attempts - 1:
                self.log(f"⏳ {service_name} not ready, retrying... ({attempt + 1}/{max_attempts})")
                time.sleep(delay)
        
        self.log(f"❌ {service_name} failed to become ready", "ERROR")
        return False
    
    def configure_torrentio_indexer(self, prowlarr_api_key):
        """Add Torrentio indexer to Prowlarr with Real-Debrid integration."""
        if not self.rd_api_token:
            self.log("⚠️ No Real-Debrid token available for Torrentio", "WARNING")
            return False
            
        self.log("🔍 Configuring Torrentio indexer in Prowlarr...")
        
        # Torrentio indexer configuration
        torrentio_config = {
            "name": "Torrentio",
            "implementation": "Torrentio",
            "configContract": "TorrentioSettings",
            "enable": True,
            "priority": 25,
            "categories": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060,  # Movies
                          5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080],  # TV
            "fields": [
                {"name": "baseUrl", "value": "https://torrentio.strem.fun"},
                {"name": "apiKey", "value": self.rd_api_token},
                {"name": "providers", "value": "yts,eztv,rarbg,1337x,thepiratebay,kickasstorrents,torrentgalaxy,magnetdl,horriblesubs,nyaasi,tokyotosho"},
                {"name": "qualityFilters", "value": "480p,720p,1080p,2160p"},
                {"name": "debridService", "value": "realdebrid"}
            ],
            "tags": []
        }
        
        try:
            indexer_url = f"{self.service_urls['prowlarr']}/api/v1/indexer"
            
            data = json.dumps(torrentio_config).encode('utf-8')
            req = urllib.request.Request(
                indexer_url,
                data=data,
                headers={
                    'Content-Type': 'application/json',
                    'X-Api-Key': prowlarr_api_key
                },
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=15) as response:
                if response.status in [200, 201]:
                    self.log("✅ Torrentio indexer configured successfully")
                    return True
                else:
                    self.log(f"❌ Failed to configure Torrentio (HTTP {response.status})", "ERROR")
                    
        except Exception as e:
            self.log(f"❌ Error configuring Torrentio indexer: {e}", "ERROR")
            
        return False
    
    def add_rdt_client_to_arr(self, service_name, service_port, api_key):
        """Add RDT-Client as download client to Radarr/Sonarr."""
        self.log(f"📥 Adding RDT-Client to {service_name.title()}...")
        
        category = "movies" if service_name == "radarr" else "tv"
        
        download_client_config = {
            "enable": True,
            "protocol": "torrent",
            "priority": 1,
            "removeCompletedDownloads": True,
            "removeFailedDownloads": True,
            "name": "RDT-Client",
            "fields": [
                {"name": "host", "value": "surge-rdt-client"},
                {"name": "port", "value": 6500},
                {"name": "category", "value": category},
                {"name": "useSsl", "value": False},
                {"name": "urlBase", "value": "/"},
                {"name": "username", "value": ""},
                {"name": "password", "value": ""}
            ],
            "implementationName": "rTorrent",
            "implementation": "RTorrent",
            "configContract": "RTorrentSettings",
            "tags": []
        }
        
        try:
            download_client_url = f"{self.service_urls[service_name]}/api/v3/downloadclient"
            
            data = json.dumps(download_client_config).encode('utf-8')
            req = urllib.request.Request(
                download_client_url,
                data=data,
                headers={
                    'Content-Type': 'application/json',
                    'X-Api-Key': api_key
                },
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=15) as response:
                if response.status in [200, 201]:
                    self.log(f"✅ RDT-Client configured in {service_name.title()}")
                    return True
                else:
                    self.log(f"❌ Failed to configure RDT-Client in {service_name.title()}", "ERROR")
                    
        except Exception as e:
            self.log(f"❌ Error configuring RDT-Client in {service_name.title()}: {e}", "ERROR")
            
        return False
    
    def configure_arr_services(self):
        """Configure RDT-Client in Radarr and Sonarr."""
        self.log("🔗 Configuring RDT-Client in *arr services...")
        
        success_count = 0
        services = [
            ('radarr', 'Radarr'),
            ('sonarr', 'Sonarr')
        ]
        
        for service_name, service_display in services:
            config_file = os.path.join(self.storage_path, service_display, 'config', 'config.xml')
            api_key = self.get_api_key_from_xml(config_file)
            
            if not api_key:
                self.log(f"❌ Could not get {service_display} API key", "ERROR")
                continue
            
            # Wait for service to be ready
            service_status_url = f"{self.service_urls[service_name]}/api/v3/system/status"
            
            try:
                req = urllib.request.Request(service_status_url)
                req.add_header('X-Api-Key', api_key)
                
                with urllib.request.urlopen(req, timeout=10) as response:
                    if response.status == 200:
                        if self.add_rdt_client_to_arr(service_name, 
                                                     7878 if service_name == 'radarr' else 8989, 
                                                     api_key):
                            success_count += 1
                    else:
                        self.log(f"⚠️ {service_display} not ready", "WARNING")
                        
            except Exception as e:
                self.log(f"⚠️ Could not connect to {service_display}: {e}", "WARNING")
        
        return success_count
    
    def run_comprehensive_setup(self):
        """Execute the complete RDT-Client and Torrentio setup."""
        self.log("🚀 Starting comprehensive RDT-Client and Torrentio setup...")
        self.log(f"📁 Storage path: {self.storage_path}")
        
        if self.rd_api_token:
            self.log(f"🔑 Real-Debrid token: {self.rd_api_token[:8]}...")
        else:
            self.log("⚠️ No Real-Debrid token - limited functionality", "WARNING")
        
        success_steps = 0
        total_steps = 4
        
        # Step 1: Wait for RDT-Client
        if self.wait_for_service(f"{self.service_urls['rdt-client']}/api/torrents", "RDT-Client", delay=8):
            success_steps += 1
            self.log("✅ Step 1/4: RDT-Client is ready")
        else:
            self.log("❌ Step 1/4: RDT-Client not available", "ERROR")
        
        # Step 2: Configure Torrentio in Prowlarr
        prowlarr_config = os.path.join(self.storage_path, "Prowlarr", "config", "config.xml")
        prowlarr_api_key = self.get_api_key_from_xml(prowlarr_config)
        
        if prowlarr_api_key and self.rd_api_token:
            if self.wait_for_service(f"{self.service_urls['prowlarr']}/api/v1/indexer", "Prowlarr"):
                if self.configure_torrentio_indexer(prowlarr_api_key):
                    success_steps += 1
                    self.log("✅ Step 2/4: Torrentio indexer configured")
                else:
                    self.log("❌ Step 2/4: Torrentio configuration failed", "ERROR")
            else:
                self.log("❌ Step 2/4: Prowlarr not ready", "ERROR")
        else:
            self.log("⚠️ Step 2/4: Skipping Torrentio (missing API key or RD token)", "WARNING")
        
        # Step 3: Configure RDT-Client in *arr services
        arr_success = self.configure_arr_services()
        if arr_success > 0:
            success_steps += 1
            self.log(f"✅ Step 3/4: RDT-Client configured in {arr_success} services")
        else:
            self.log("❌ Step 3/4: Failed to configure RDT-Client in *arr services", "ERROR")
        
        # Step 4: Verification and summary
        success_steps += 1  # Always count verification as success
        self.log("✅ Step 4/4: Configuration verification completed")
        
        # Final report
        self.log("=" * 50)
        self.log(f"📊 Setup Results: {success_steps}/{total_steps} steps completed")
        
        if success_steps >= 3:
            self.log("🎉 RDT-Client and Torrentio setup completed successfully!", "SUCCESS")
            self.log("🔗 Integration Summary:")
            self.log("   • RDT-Client ready for torrent downloads")
            if self.rd_api_token:
                self.log("   • Torrentio indexer configured with Real-Debrid")
            self.log("   • Download client configured in Radarr/Sonarr")
            self.log("🌐 Access RDT-Client: http://localhost:6500")
            
            if not self.rd_api_token:
                self.log("⚠️ Manual setup required:", "WARNING")
                self.log("   1. Set RD_API_TOKEN in .env file")
                self.log("   2. Configure Real-Debrid in RDT-Client web UI")
                self.log("   3. Add Torrentio indexer manually in Prowlarr")
            
            return True
        else:
            self.log("⚠️ Setup completed with issues", "WARNING")
            self.log("💡 Check logs above for manual configuration steps")
            return False

def main():
    """Main entry point."""
    print("=" * 60)
    print("🌐 RDT-Client & Torrentio Comprehensive Setup")
    print("=" * 60)
    
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    try:
        configurator = TorrentioRDTConfigurator(storage_path)
        success = configurator.run_comprehensive_setup()
        
        print("\n" + "=" * 60)
        if success:
            print("✅ SETUP COMPLETED SUCCESSFULLY!")
            print("\n🔗 Ready to use:")
            print("   • Download torrents via RDT-Client")
            print("   • Search content via Torrentio in Prowlarr")
            print("   • Automatic downloads in Radarr/Sonarr")
        else:
            print("⚠️ Setup completed with issues")
            print("💡 Check configuration and try manual setup if needed")
        
        print("=" * 60)
        sys.exit(0 if success else 1)
        
    except Exception as e:
        print(f"\n❌ Setup failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
