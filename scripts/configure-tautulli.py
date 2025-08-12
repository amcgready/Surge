#!/usr/bin/env python3
"""
Tautulli Auto-Configuration for Surge

Configures Tautulli to connect to Plex automatically.
"""

import os
import sys
import configparser
from datetime import datetime

class TautulliConfigurator:
    def __init__(self, storage_path=None):
        self.storage_path = storage_path or '/opt/surge'
        self.config_dir = f"{self.storage_path}/Tautulli/config"
        self.config_file = f"{self.config_dir}/config.ini"
        
        # Load environment variables
        self.plex_url = os.environ.get('PLEX_URL', 'http://plex:32400')
        self.plex_token = os.environ.get('PLEX_TOKEN', '')
        
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {"INFO": "ℹ️", "SUCCESS": "✅", "WARNING": "⚠️", "ERROR": "❌"}
        icon = icons.get(level, "ℹ️")
        print(f"[{timestamp}] {icon} {message}")
        sys.stdout.flush()
    
    def configure_tautulli(self):
        """Configure Tautulli with Plex connection."""
        self.log("Configuring Tautulli connection to Plex...", "INFO")
        
        # Create config directory if it doesn't exist
        os.makedirs(self.config_dir, exist_ok=True)
        
        # Load or create config
        config = configparser.ConfigParser()
        
        if os.path.exists(self.config_file):
            config.read(self.config_file)
        
        # Ensure required sections exist
        if not config.has_section('General'):
            config.add_section('General')
        
        if not config.has_section('PlexPy'):
            config.add_section('PlexPy')
        
        # Configure Plex connection
        config.set('General', 'pms_identifier', '')
        config.set('General', 'pms_ip', 'plex')
        config.set('General', 'pms_port', '32400')
        config.set('General', 'pms_token', self.plex_token)
        config.set('General', 'pms_ssl', '0')
        config.set('General', 'pms_url_manual', '1')
        config.set('General', 'pms_name', 'SurgePlex')
        config.set('General', 'pms_is_remote', '0')
        config.set('General', 'pms_is_cloud', '0')
        
        # Generate API key if not exists
        if not config.has_option('General', 'api_key') or not config.get('General', 'api_key'):
            import uuid
            api_key = str(uuid.uuid4()).replace('-', '')
            config.set('General', 'api_key', api_key)
            self.log(f"Generated Tautulli API key: {api_key[:8]}...", "SUCCESS")
        
        # Basic settings
        config.set('General', 'first_run_complete', '1')
        config.set('General', 'launch_startup', '0')
        config.set('General', 'launch_browser', '0')
        config.set('General', 'log_level', '1')
        config.set('General', 'check_github', '1')
        config.set('General', 'auto_update', '0')
        
        # Write configuration
        with open(self.config_file, 'w') as f:
            config.write(f)
        
        self.log("✅ Tautulli configured successfully", "SUCCESS")
        self.log(f"Plex URL: {self.plex_url}", "INFO")
        self.log("Restart Tautulli to apply changes", "INFO")

def main():
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    configurator = TautulliConfigurator(storage_path)
    
    try:
        configurator.configure_tautulli()
        return 0
    except Exception as e:
        configurator.log(f"Configuration failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
