#!/usr/bin/env python3

"""
Plex Library Configuration Script for Surge
Automatically creates Plex libraries based on CineSync folder structure
"""

import urllib.request
import xml.etree.ElementTree as ET
import os
import time
import urllib.parse
import sys

class PlexLibraryManager:
    def __init__(self, plex_url="http://localhost:32400", storage_path=None):
        self.plex_url = plex_url.rstrip('/')
        self.storage_path = storage_path or self.find_storage_path()
        self.plex_token = None
        self.server_name = None
        
    def find_storage_path(self):
        """Find the correct storage path for configurations."""
        possible_paths = [
            os.environ.get('DATA_ROOT'),
            '/opt/surge',
            '/mnt/mycloudpr4100/Surge',
            './data'
        ]
        
        for path in possible_paths:
            if path and os.path.exists(path):
                return path
        
        return '/opt/surge'  # Default fallback
    
    def get_plex_token(self):
        """Get Plex token from configuration."""
        if self.plex_token:
            return self.plex_token
            
        # Try to get from Plex config
        plex_config = os.path.join(self.storage_path, "Plex", "config", "Preferences.xml")
        
        if os.path.exists(plex_config):
            try:
                tree = ET.parse(plex_config)
                root = tree.getroot()
                
                token = root.get('PlexOnlineToken')
                if token:
                    self.plex_token = token.strip()
                    return self.plex_token
            except Exception as e:
                print(f"❌ Error reading Plex config: {e}")
        
        # Try to get from environment
        self.plex_token = os.environ.get('PLEX_TOKEN')
        if self.plex_token:
            return self.plex_token
            
        print("⚠️ Plex token not found")
        return None
    
    def test_plex_connection(self):
        """Test connection to Plex server."""
        token = self.get_plex_token()
        if not token:
            return False
            
        try:
            url = f"{self.plex_url}/?X-Plex-Token={token}"
            req = urllib.request.Request(url, headers={'User-Agent': 'Surge-PlexConfig/1.0'})
            response = urllib.request.urlopen(req, timeout=10)
            
            if response.status == 200:
                # Parse XML to get server info
                data = response.read().decode('utf-8')
                root = ET.fromstring(data)
                self.server_name = root.get('friendlyName', 'Plex Media Server')
                print(f"✅ Connected to Plex server: {self.server_name}")
                return True
            else:
                print(f"❌ Plex connection failed: HTTP {response.status}")
                return False
                
        except Exception as e:
            print(f"❌ Failed to connect to Plex: {e}")
            return False
    
    def get_existing_libraries(self):
        """Get list of existing Plex libraries."""
        token = self.get_plex_token()
        if not token:
            return []
            
        try:
            url = f"{self.plex_url}/library/sections?X-Plex-Token={token}"
            req = urllib.request.Request(url, headers={'User-Agent': 'Surge-PlexConfig/1.0'})
            response = urllib.request.urlopen(req, timeout=10)
            
            if response.status == 200:
                data = response.read().decode('utf-8')
                root = ET.fromstring(data)
                
                libraries = []
                for directory in root.findall('.//Directory'):
                    libraries.append({
                        'key': directory.get('key'),
                        'title': directory.get('title'),
                        'type': directory.get('type'),
                        'agent': directory.get('agent'),
                        'language': directory.get('language'),
                        'location': [loc.get('path') for loc in directory.findall('.//Location')]
                    })
                
                return libraries
            else:
                print(f"❌ Failed to get libraries: HTTP {response.status}")
                return []
                
        except Exception as e:
            print(f"❌ Error getting existing libraries: {e}")
            return []
    
    def get_cinesync_folders(self):
        """Get CineSync folder structure from configuration."""
        cinesync_folders = {
            'Movies': '/data/movies',
            'TV Shows': '/data/tv', 
            'Anime Movies': '/data/movies/anime',
            'Anime Series': '/data/tv/anime'
        }
        
        # Try to read from CineSync config or environment variables
        env_mappings = {
            'CINESYNC_CUSTOM_MOVIE_FOLDER': ('Movies', '/data/movies'),
            'CINESYNC_CUSTOM_SHOW_FOLDER': ('TV Shows', '/data/tv'),
            'CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER': ('Anime Movies', '/data/movies/anime'),
            'CINESYNC_CUSTOM_ANIME_SHOW_FOLDER': ('Anime Series', '/data/tv/anime')
        }
        
        for env_var, (lib_name, _) in env_mappings.items():
            custom_folder = os.environ.get(env_var)
            if custom_folder:
                # Update the path but keep the structure
                if 'movie' in env_var.lower():
                    cinesync_folders[lib_name] = f"/data/movies/{custom_folder}" if custom_folder != 'Movies' else '/data/movies'
                else:
                    cinesync_folders[lib_name] = f"/data/tv/{custom_folder}" if custom_folder != 'Shows' else '/data/tv'
        
        return cinesync_folders
    
    def create_library(self, name, library_type, path, agent=None, language='en'):
        """Create a new Plex library."""
        token = self.get_plex_token()
        if not token:
            return False
            
        # Set default agents based on type
        if not agent:
            if library_type == 'movie':
                agent = 'com.plexapp.agents.themoviedb'
            elif library_type == 'show':
                agent = 'com.plexapp.agents.thetvdb'
            else:
                agent = 'com.plexapp.agents.none'
        
        try:
            # Create the library
            params = {
                'name': name,
                'type': library_type,
                'agent': agent,
                'language': language,
                'location': path,
                'X-Plex-Token': token
            }
            
            url = f"{self.plex_url}/library/sections"
            data = urllib.parse.urlencode(params).encode('utf-8')
            
            req = urllib.request.Request(url, data=data, method='POST')
            req.add_header('User-Agent', 'Surge-PlexConfig/1.0')
            req.add_header('Content-Type', 'application/x-www-form-urlencoded')
            
            response = urllib.request.urlopen(req, timeout=30)
            
            if response.status in [200, 201]:
                print(f"✅ Created library '{name}' at {path}")
                return True
            else:
                print(f"❌ Failed to create library '{name}': HTTP {response.status}")
                return False
                
        except Exception as e:
            print(f"❌ Error creating library '{name}': {e}")
            return False
    
    def update_server_name(self, new_name):
        """Update Plex server name."""
        token = self.get_plex_token()
        if not token:
            return False
            
        try:
            params = {
                'friendlyName': new_name,
                'X-Plex-Token': token
            }
            
            url = f"{self.plex_url}/:/prefs"
            data = urllib.parse.urlencode(params).encode('utf-8')
            
            req = urllib.request.Request(url, data=data, method='PUT')
            req.add_header('User-Agent', 'Surge-PlexConfig/1.0')
            req.add_header('Content-Type', 'application/x-www-form-urlencoded')
            
            response = urllib.request.urlopen(req, timeout=30)
            
            if response.status == 200:
                print(f"✅ Updated server name to '{new_name}'")
                self.server_name = new_name
                return True
            else:
                print(f"❌ Failed to update server name: HTTP {response.status}")
                return False
                
        except Exception as e:
            print(f"❌ Error updating server name: {e}")
            return False
    
    def configure_all_libraries(self, server_name=None):
        """Configure all CineSync-based libraries."""
        print("🎬 Configuring Plex libraries based on CineSync structure...")
        
        # Test connection first
        if not self.test_plex_connection():
            print("❌ Cannot connect to Plex server")
            return False
        
        # Update server name if provided
        if server_name and server_name != self.server_name:
            if not self.update_server_name(server_name):
                print("⚠️ Failed to update server name, continuing with library creation...")
        
        # Get existing libraries
        existing_libs = self.get_existing_libraries()
        existing_names = [lib['title'] for lib in existing_libs]
        
        print(f"📚 Found {len(existing_libs)} existing libraries: {', '.join(existing_names)}")
        
        # Get CineSync folder structure
        cinesync_folders = self.get_cinesync_folders()
        
        # Create libraries based on CineSync structure
        success_count = 0
        total_count = 0
        
        for lib_name, lib_path in cinesync_folders.items():
            total_count += 1
            
            # Skip if library already exists
            if lib_name in existing_names:
                print(f"📚 Library '{lib_name}' already exists, skipping...")
                success_count += 1
                continue
            
            # Determine library type
            if 'movie' in lib_name.lower() or lib_name == 'Movies':
                lib_type = 'movie'
            else:
                lib_type = 'show'
            
            # Create the library
            if self.create_library(lib_name, lib_type, lib_path):
                success_count += 1
                time.sleep(2)  # Brief pause between creations
            else:
                print(f"❌ Failed to create library '{lib_name}'")
        
        print(f"\n🎯 Library Configuration Complete: {success_count}/{total_count} libraries configured")
        
        if success_count > 0:
            print("💡 Tip: Libraries may take a few minutes to scan and populate")
            print(f"💡 Access your Plex server at: {self.plex_url}/web")
        
        return success_count == total_count

def main():
    """Main function for CLI usage."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Configure Plex libraries for Surge')
    parser.add_argument('--plex-url', default='http://localhost:32400', 
                       help='Plex server URL (default: http://localhost:32400)')
    parser.add_argument('--storage-path', help='Storage path for configurations')
    parser.add_argument('--server-name', help='New server name to set')
    parser.add_argument('--token', help='Plex authentication token')
    parser.add_argument('--test-only', action='store_true', 
                       help='Only test connection, don\'t create libraries')
    
    args = parser.parse_args()
    
    # Create manager
    manager = PlexLibraryManager(args.plex_url, args.storage_path)
    
    # Set token if provided
    if args.token:
        manager.plex_token = args.token
    
    if args.test_only:
        # Just test connection
        if manager.test_plex_connection():
            print("✅ Plex connection test successful")
            return 0
        else:
            print("❌ Plex connection test failed")
            return 1
    else:
        # Configure all libraries
        if manager.configure_all_libraries(args.server_name):
            print("✅ Plex library configuration completed successfully")
            return 0
        else:
            print("❌ Some libraries failed to configure")
            return 1

if __name__ == '__main__':
    sys.exit(main())
