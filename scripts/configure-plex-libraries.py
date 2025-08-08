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
            os.environ.get('STORAGE_PATH'),  # STORAGE_PATH environment variable
            os.environ.get('DATA_ROOT'),     # DATA_ROOT environment variable 
            '/opt/surge',                    # Default installation path
            './data'                        # Local data directory
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
        try:
            # First try without token to see if server is running
            url = f"{self.plex_url}"
            req = urllib.request.Request(url, headers={'User-Agent': 'Surge-PlexConfig/1.0'})
            response = urllib.request.urlopen(req, timeout=10)
            
            if response.status == 200:
                print("✅ Plex server is running")
                
                # Try to get token if available
                token = self.get_plex_token()
                if token:
                    # Test with token
                    url_with_token = f"{self.plex_url}/?X-Plex-Token={token}"
                    req_with_token = urllib.request.Request(url_with_token, headers={'User-Agent': 'Surge-PlexConfig/1.0'})
                    response_with_token = urllib.request.urlopen(req_with_token, timeout=10)
                    
                    if response_with_token.status == 200:
                        data = response_with_token.read().decode('utf-8')
                        root = ET.fromstring(data)
                        self.server_name = root.get('friendlyName', 'Plex Media Server')
                        print(f"✅ Connected to Plex server with token: {self.server_name}")
                        return True
                
                # If no token or token doesn't work, proceed without it for initial setup
                print("⚠️ No Plex token available, but server is accessible. Proceeding with initial setup...")
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
        """Get CineSync folder structure by reading the actual configuration from environment and docker-compose."""
        cinesync_folders = {}
        
        # Define the media base paths inside the container
        media_base = "/data"
        
        # Read CineSync configuration from environment or docker-compose defaults
        # This ensures we match exactly what the user has configured
        
        # Check if CineSync layout is enabled (if disabled, no custom folders are created)
        cinesync_layout = os.environ.get('CINESYNC_LAYOUT', 'true').lower() == 'true'
        if not cinesync_layout:
            print("⚠️ CineSync layout is disabled - using basic folder structure")
            cinesync_folders['Movies'] = f"{media_base}/movies"
            cinesync_folders['TV Shows'] = f"{media_base}/tv"
            return cinesync_folders
        
        # Get separation settings (determines which extra libraries are created)
        anime_separation = os.environ.get('CINESYNC_ANIME_SEPARATION', 'true').lower() == 'true'
        k4_separation = os.environ.get('CINESYNC_4K_SEPARATION', 'false').lower() == 'true'
        kids_separation = os.environ.get('CINESYNC_KIDS_SEPARATION', 'false').lower() == 'true'
        
        # Get custom folder names from environment (these are what users can customize)
        movie_folder = os.environ.get('CINESYNC_CUSTOM_MOVIE_FOLDER', 'Movies')
        show_folder = os.environ.get('CINESYNC_CUSTOM_SHOW_FOLDER', 'TV Series')
        k4_movie_folder = os.environ.get('CINESYNC_CUSTOM_4KMOVIE_FOLDER', '4K Movies')
        k4_show_folder = os.environ.get('CINESYNC_CUSTOM_4KSHOW_FOLDER', '4K Series')
        anime_movie_folder = os.environ.get('CINESYNC_CUSTOM_ANIME_MOVIE_FOLDER', 'Anime Movies')
        anime_show_folder = os.environ.get('CINESYNC_CUSTOM_ANIME_SHOW_FOLDER', 'Anime Series')
        kids_movie_folder = os.environ.get('CINESYNC_CUSTOM_KIDS_MOVIE_FOLDER', 'Kids Movies')
        kids_show_folder = os.environ.get('CINESYNC_CUSTOM_KIDS_SHOW_FOLDER', 'Kids Series')
        
        # Always create the main libraries (these are required)
        cinesync_folders[movie_folder] = f"{media_base}/{movie_folder}"
        cinesync_folders[show_folder] = f"{media_base}/{show_folder}"
        
        # Create additional libraries only if the corresponding separation is enabled
        if k4_separation:
            cinesync_folders[k4_movie_folder] = f"{media_base}/{k4_movie_folder}"
            cinesync_folders[k4_show_folder] = f"{media_base}/{k4_show_folder}"
            print(f"📺 4K separation enabled - will create {k4_movie_folder} and {k4_show_folder} libraries")
        
        if anime_separation:
            cinesync_folders[anime_movie_folder] = f"{media_base}/{anime_movie_folder}"
            cinesync_folders[anime_show_folder] = f"{media_base}/{anime_show_folder}"
            print(f"🎌 Anime separation enabled - will create {anime_movie_folder} and {anime_show_folder} libraries")
        
        if kids_separation:
            cinesync_folders[kids_movie_folder] = f"{media_base}/{kids_movie_folder}"
            cinesync_folders[kids_show_folder] = f"{media_base}/{kids_show_folder}"
            print(f"👶 Kids separation enabled - will create {kids_movie_folder} and {kids_show_folder} libraries")
        
        return cinesync_folders
    
    def create_basic_library_via_api(self, lib_name, lib_type, lib_path):
        """Create library without requiring token - using direct API calls."""
        try:
            # For initial setup, we'll attempt to use the unclaimed server approach
            print(f"🔧 Attempting to create library '{lib_name}' at {lib_path}")
            
            # Try multiple approaches for library creation
            urls_to_try = [
                f"{self.plex_url}/library/sections",
                f"{self.plex_url}/library/sections?includeDetails=1"
            ]
            
            for url in urls_to_try:
                try:
                    # Prepare library creation data
                    create_data = {
                        'name': lib_name,
                        'type': lib_type,
                        'agent': 'tv.plex.agents.movie' if lib_type == 'movie' else 'tv.plex.agents.series',
                        'scanner': 'Plex Movie' if lib_type == 'movie' else 'Plex TV Series',
                        'language': 'en-US',
                        'location': lib_path
                    }
                    
                    # Convert to URL encoded data
                    encoded_data = urllib.parse.urlencode(create_data).encode('utf-8')
                    
                    # Make the request
                    req = urllib.request.Request(url, data=encoded_data, method='POST')
                    req.add_header('Content-Type', 'application/x-www-form-urlencoded')
                    req.add_header('User-Agent', 'Surge-PlexConfig/1.0')
                    
                    response = urllib.request.urlopen(req, timeout=30)
                    
                    if response.status in [200, 201]:
                        print(f"✅ Library '{lib_name}' created successfully")
                        return True
                    else:
                        print(f"⚠️ Library creation returned status: {response.status}")
                        
                except Exception as e:
                    print(f"⚠️ Library creation attempt failed: {e}")
                    continue
            
            # If direct creation fails, create a simple preferences file to help with setup
            self.create_basic_plex_setup()
            return False
            
        except Exception as e:
            print(f"❌ Failed to create library '{lib_name}': {e}")
            return False
    
    def create_basic_plex_setup(self):
        """Create basic Plex setup files to help with initial configuration."""
        try:
            plex_config_dir = os.path.join(self.storage_path, "Plex", "config", "Library", "Application Support", "Plex Media Server")
            os.makedirs(plex_config_dir, exist_ok=True)
            
            # Create a basic preferences file
            prefs_file = os.path.join(plex_config_dir, "Preferences.xml")
            if not os.path.exists(prefs_file):
                prefs_content = '''<?xml version="1.0" encoding="utf-8"?>
<Preferences FriendlyName="Surge Plex Server" 
             AcceptedEULA="1" 
             PublishServerOnPlexOnlineKey="1"
             PlexOnlineHome="1"
             PlexOnlineUsername=""
             PlexOnlineToken="">
</Preferences>'''
                with open(prefs_file, 'w') as f:
                    f.write(prefs_content)
                print("✅ Created basic Plex preferences file")
            
        except Exception as e:
            print(f"⚠️ Could not create basic Plex setup: {e}")
    
    def create_library(self, lib_name, lib_type, lib_path, agent=None, language='en'):
        """Create a new Plex library."""
        token = self.get_plex_token()
        
        # If no token available, try the basic API approach
        if not token:
            print(f"⚠️ No token available, trying basic library creation for '{lib_name}'")
            return self.create_basic_library_via_api(lib_name, lib_type, lib_path)
            
        # Set default agents based on type
        if not agent:
            if lib_type == 'movie':
                agent = 'com.plexapp.agents.themoviedb'
            elif lib_type == 'show':
                agent = 'com.plexapp.agents.thetvdb'
            else:
                agent = 'com.plexapp.agents.none'
        
        try:
            # Create the library
            params = {
                'name': lib_name,
                'type': lib_type,
                'agent': agent,
                'language': language,
                'location': lib_path,
                'X-Plex-Token': token
            }
            
            url = f"{self.plex_url}/library/sections"
            data = urllib.parse.urlencode(params).encode('utf-8')
            
            req = urllib.request.Request(url, data=data, method='POST')
            req.add_header('User-Agent', 'Surge-PlexConfig/1.0')
            req.add_header('Content-Type', 'application/x-www-form-urlencoded')
            
            response = urllib.request.urlopen(req, timeout=30)
            
            if response.status in [200, 201]:
                print(f"✅ Created library '{lib_name}' at {lib_path}")
                return True
            else:
                print(f"❌ Failed to create library '{lib_name}': HTTP {response.status}")
                return False
                
        except Exception as e:
            print(f"❌ Error creating library '{lib_name}': {e}")
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
        print("🔍 Reading CineSync configuration...")
        
        # Test connection first
        if not self.test_plex_connection():
            print("❌ Cannot connect to Plex server")
            return False
        
        # Update server name if provided and we have a token
        if server_name and server_name != self.server_name:
            token = self.get_plex_token()
            if token:
                if not self.update_server_name(server_name):
                    print("⚠️ Failed to update server name, continuing with library creation...")
            else:
                print("⚠️ No token available for server name update, continuing with library creation...")
        
        # Get existing libraries (if token is available)
        existing_libs = []
        token = self.get_plex_token()
        if token:
            existing_libs = self.get_existing_libraries()
        
        existing_names = [lib['title'] for lib in existing_libs]
        
        if existing_names:
            print(f"📚 Found {len(existing_libs)} existing libraries: {', '.join(existing_names)}")
        else:
            print("📚 No existing libraries found or no token available to check")
        
        # Get CineSync folder structure
        cinesync_folders = self.get_cinesync_folders()
        
        if not cinesync_folders:
            print("❌ No CineSync folders detected. Check your CineSync configuration.")
            return False
        
        print(f"📁 Detected CineSync folder structure based on user configuration:")
        for lib_name, lib_path in cinesync_folders.items():
            lib_type = 'movie' if any(keyword in lib_name.lower() for keyword in ['movie', 'film']) or lib_name.lower() in ['movies', '4kmovies', 'animemovies', 'kidsmovies'] else 'show'
            print(f"  - {lib_name} → {lib_path} ({lib_type})")
        print()
        
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
            
            # Determine library type based on folder name
            if any(keyword in lib_name.lower() for keyword in ['movie', 'film']):
                lib_type = 'movie'
            elif any(keyword in lib_name.lower() for keyword in ['show', 'series', 'tv']):
                lib_type = 'show'
            else:
                # Default based on common patterns
                if lib_name.lower() in ['movies', '4kmovies', 'animemovies', 'kidsmovies']:
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
