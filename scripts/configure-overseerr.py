#!/usr/bin/env python3

"""
Overseerr Configuration Script for Surge
This script configures Overseerr's settings.json with API keys from Radarr, Sonarr, and Tautulli.
"""

import os
import sys
import json
import uuid
import xml.etree.ElementTree as ET
import configparser

class OverseerrConfigurator:
    def __init__(self, storage_path=None):
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.storage_path = storage_path or '/opt/surge'
        
    def log(self, message, level="INFO"):
        print(f"[{level}] {message}")
        
    def generate_api_key(self):
        """Generate a random API key."""
        return str(uuid.uuid4()).replace('-', '')
    
    def get_radarr_api_key(self):
        """Get Radarr API key from config.xml."""
        config_path = os.path.join(self.project_root, 'config', 'radarr', 'config.xml')
        if os.path.exists(config_path):
            try:
                tree = ET.parse(config_path)
                root = tree.getroot()
                api_key_element = root.find('ApiKey')
                if api_key_element is not None and api_key_element.text:
                    return api_key_element.text.strip()
            except Exception as e:
                self.log(f"Error reading Radarr config: {e}", "ERROR")
        return None
    
    def get_sonarr_api_key(self):
        """Get Sonarr API key from config.xml."""
        config_path = os.path.join(self.project_root, 'config', 'sonarr', 'config.xml')
        if os.path.exists(config_path):
            try:
                tree = ET.parse(config_path)
                root = tree.getroot()
                api_key_element = root.find('ApiKey')
                if api_key_element is not None and api_key_element.text:
                    return api_key_element.text.strip()
            except Exception as e:
                self.log(f"Error reading Sonarr config: {e}", "ERROR")
        return None
    
    def get_or_create_tautulli_api_key(self):
        """Get or create Tautulli API key from config.ini."""
        config_path = os.path.join(self.project_root, 'config', 'tautulli', 'config.ini')
        
        if not os.path.exists(config_path):
            self.log("Tautulli config not found", "WARNING")
            return None
            
        try:
            config = configparser.ConfigParser()
            config.read(config_path)
            
            # Check if API key already exists
            if config.has_section('General') and config.has_option('General', 'api_key'):
                api_key = config.get('General', 'api_key')
                if api_key and api_key.strip():
                    self.log(f"Found existing Tautulli API key: {api_key[:8]}...")
                    return api_key.strip()
            
            # Generate new API key
            new_api_key = self.generate_api_key()
            
            # Ensure General section exists
            if not config.has_section('General'):
                config.add_section('General')
            
            # Add API key
            config.set('General', 'api_key', new_api_key)
            
            # Write back to file
            with open(config_path, 'w') as configfile:
                config.write(configfile)
            
            self.log(f"Generated new Tautulli API key: {new_api_key[:8]}...")
            return new_api_key
            
        except Exception as e:
            self.log(f"Error handling Tautulli config: {e}", "ERROR")
            return None
    
    def create_overseerr_settings(self, radarr_api_key, sonarr_api_key, tautulli_api_key):
        """Create Overseerr settings.json with service configurations."""
        
        settings = {
            "main": {
                "apiKey": self.generate_api_key(),
                "applicationTitle": "Surge Overseerr",
                "applicationUrl": "",
                "csrfProtection": False,
                "cacheImages": False,
                "defaultPermissions": 2,
                "hideAvailable": False,
                "localLogin": True,
                "newPlexLogin": True,
                "region": "US",
                "originalLanguage": "en",
                "trustProxy": False,
                "csrfProtection": False
            },
            "plex": {
                "name": "Plex",
                "hostname": "surge-plex",
                "port": 32400,
                "useSsl": False,
                "libraries": [],
                "webAppUrl": "http://surge-plex:32400"
            },
            "radarr": [],
            "sonarr": [],
            "tautulli": []
        }
        
        # Add Radarr configuration
        if radarr_api_key:
            settings["radarr"].append({
                "id": 1,
                "name": "Radarr",
                "hostname": "surge-radarr",
                "port": 7878,
                "apiKey": radarr_api_key,
                "useSsl": False,
                "baseUrl": "",
                "activeProfileId": 1,
                "activeProfileName": "Any",
                "activeDirectory": "/movies",
                "is4k": False,
                "minimumAvailability": "announced",
                "tags": [],
                "isDefault": True,
                "externalUrl": "",
                "syncEnabled": True,
                "preventSearch": False
            })
        
        # Add Sonarr configuration
        if sonarr_api_key:
            settings["sonarr"].append({
                "id": 1,
                "name": "Sonarr",
                "hostname": "surge-sonarr", 
                "port": 8989,
                "apiKey": sonarr_api_key,
                "useSsl": False,
                "baseUrl": "",
                "activeProfileId": 1,
                "activeProfileName": "Any",
                "rootFolder": "/tv",
                "languageProfileId": 1,
                "tags": [],
                "isDefault": True,
                "externalUrl": "",
                "syncEnabled": True,
                "preventSearch": False,
                "enableSeasonFolders": True
            })
        
        # Add Tautulli configuration
        if tautulli_api_key:
            settings["tautulli"].append({
                "id": 1,
                "name": "Tautulli",
                "hostname": "surge-tautulli",
                "port": 8181,
                "apiKey": tautulli_api_key,
                "useSsl": False,
                "baseUrl": "",
                "externalUrl": ""
            })
        
        return settings
    
    def save_overseerr_settings(self, settings, overseerr_config_dir):
        """Save settings to Overseerr's settings.json file."""
        
        # Ensure directory exists
        os.makedirs(overseerr_config_dir, exist_ok=True)
        
        settings_file = os.path.join(overseerr_config_dir, 'settings.json')
        
        try:
            # If settings file exists, try to merge with existing settings
            if os.path.exists(settings_file):
                self.log(f"Found existing settings file: {settings_file}")
                try:
                    with open(settings_file, 'r') as f:
                        existing_settings = json.load(f)
                    
                    # Only update service configurations, preserve other settings
                    if 'radarr' in settings and settings['radarr']:
                        existing_settings['radarr'] = settings['radarr']
                        self.log("Updated Radarr configuration in existing settings")
                    
                    if 'sonarr' in settings and settings['sonarr']:
                        existing_settings['sonarr'] = settings['sonarr']
                        self.log("Updated Sonarr configuration in existing settings")
                    
                    if 'tautulli' in settings and settings['tautulli']:
                        existing_settings['tautulli'] = settings['tautulli']
                        self.log("Updated Tautulli configuration in existing settings")
                    
                    settings = existing_settings
                    
                except Exception as e:
                    self.log(f"Error reading existing settings, creating new: {e}", "WARNING")
            
            # Write settings file
            with open(settings_file, 'w') as f:
                json.dump(settings, f, indent=2)
            
            self.log(f"✅ Overseerr settings saved to: {settings_file}")
            return True
            
        except Exception as e:
            self.log(f"Error saving Overseerr settings: {e}", "ERROR")
            return False
    
    def configure_overseerr(self):
        """Main function to configure Overseerr with service API keys."""
        self.log("🔧 Configuring Overseerr with Radarr, Sonarr, and Tautulli...")
        
        # Get API keys
        radarr_api_key = self.get_radarr_api_key()
        sonarr_api_key = self.get_sonarr_api_key()
        tautulli_api_key = self.get_or_create_tautulli_api_key()
        
        # Report what we found
        self.log(f"Radarr API key: {'Found' if radarr_api_key else 'Not found'}")
        self.log(f"Sonarr API key: {'Found' if sonarr_api_key else 'Not found'}")
        self.log(f"Tautulli API key: {'Found/Generated' if tautulli_api_key else 'Not found'}")
        
        if not any([radarr_api_key, sonarr_api_key, tautulli_api_key]):
            self.log("No API keys found. Run API key injection first.", "ERROR")
            return False
        
        # Create settings
        settings = self.create_overseerr_settings(radarr_api_key, sonarr_api_key, tautulli_api_key)
        
        # Determine Overseerr config directory
        possible_dirs = [
            os.path.join(self.project_root, 'config', 'overseerr'),
            os.path.join(self.storage_path, 'Overseerr', 'config'),
            os.path.join(self.storage_path, 'overseerr', 'config'),
        ]
        
        # Use the first directory that exists or create in project config
        overseerr_config_dir = possible_dirs[0]
        for dir_path in possible_dirs:
            if os.path.exists(dir_path):
                overseerr_config_dir = dir_path
                break
        
        # Save settings
        success = self.save_overseerr_settings(settings, overseerr_config_dir)
        
        if success:
            self.log("✅ Overseerr configuration completed successfully!")
            self.log("Restart Overseerr container for changes to take effect:")
            self.log("  docker-compose restart overseerr")
        
        return success

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Configure Overseerr with Surge service API keys')
    parser.add_argument('--storage-path', help='Storage path for configs', default='/opt/surge')
    
    args = parser.parse_args()
    
    configurator = OverseerrConfigurator(args.storage_path)
    success = configurator.configure_overseerr()
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
