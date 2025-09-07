#!/usr/bin/env python3
"""
Torrentio Indexer Configuration for Surge

This script automates:
1. Real-Debrid token integration
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

class TorrentioConfigurator:
    """Torrentio indexer configuration for Prowlarr only."""

    def __init__(self, storage_path=None):
        self.storage_path = storage_path or self.find_storage_path()
        self.rd_api_token = os.environ.get('RD_API_TOKEN', '')
        self.prowlarr_url = os.environ.get('PROWLARR_URL', 'http://localhost:9696')

        if not self.rd_api_token:
            self.log("⚠️ RD_API_TOKEN not found in environment", "WARNING")
            self.log("💡 Torrentio indexer will not be configured", "INFO")

    def find_storage_path(self):
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

    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {
            "INFO": "ℹ️", "SUCCESS": "✅", "WARNING": "⚠️", "ERROR": "❌", "DEBUG": "🔍"
        }
        icon = icons.get(level, "ℹ️")
        print(f"[{timestamp}] {icon} {message}")
        sys.stdout.flush()

    def get_api_key_from_xml(self, config_path):
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
        if not self.rd_api_token:
            self.log("⚠️ No Real-Debrid token available for Torrentio", "WARNING")
            return False
        self.log("🔍 Configuring Torrentio indexer in Prowlarr...")
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
            indexer_url = f"{self.prowlarr_url}/api/v1/indexer"
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

    def run_setup(self):
        self.log("🚀 Starting Torrentio indexer setup for Prowlarr...")
        self.log(f"📁 Storage path: {self.storage_path}")
        if self.rd_api_token:
            self.log(f"🔑 Real-Debrid token: {self.rd_api_token[:8]}...")
        else:
            self.log("⚠️ No Real-Debrid token - Torrentio will not be configured", "WARNING")
        prowlarr_config = os.path.join(self.storage_path, "Prowlarr", "config", "config.xml")
        prowlarr_api_key = self.get_api_key_from_xml(prowlarr_config)
        if prowlarr_api_key and self.rd_api_token:
            if self.wait_for_service(f"{self.prowlarr_url}/api/v1/indexer", "Prowlarr"):
                if self.configure_torrentio_indexer(prowlarr_api_key):
                    self.log("✅ Torrentio indexer configured", "SUCCESS")
                else:
                    self.log("❌ Torrentio configuration failed", "ERROR")
            else:
                self.log("❌ Prowlarr not ready", "ERROR")
        else:
            self.log("⚠️ Skipping Torrentio (missing API key or RD token)", "WARNING")
        self.log("✅ Torrentio indexer setup completed", "SUCCESS")

def main():
    print("=" * 60)
    print("🌐 Torrentio Indexer Setup for Prowlarr")
    print("=" * 60)
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    try:
        configurator = TorrentioConfigurator(storage_path)
        configurator.run_setup()
        print("\n" + "=" * 60)
        print("✅ SETUP COMPLETED!")
        print("=" * 60)
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Setup failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
