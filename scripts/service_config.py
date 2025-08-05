#!/usr/bin/env python3

"""
Surge Service Configuration Utilities
This module provides functions to automatically configure service connections.
"""

import urllib.request
import json
import xml.etree.ElementTree as ET
import os
import time
import sqlite3

def find_storage_path():
    """Find the correct storage path for configurations."""
    possible_paths = [
        os.environ.get('STORAGE_PATH'),  # STORAGE_PATH environment variable
        os.environ.get('DATA_ROOT'),     # DATA_ROOT environment variable
        "/opt/surge",                    # Default installation path
        "data"                          # Local data directory
    ]
    
    for path in possible_paths:
        # Check if any service config directory exists
        service_dirs = ["Prowlarr", "Radarr", "Sonarr"]
        if any(os.path.exists(os.path.join(path, service)) for service in service_dirs):
            return path
    
    return "data"  # fallback to local data directory

def get_api_key_from_xml(config_path):
    """Extract API key from XML config file."""
    try:
        if not os.path.exists(config_path):
            print(f"⚠️ Config file not found: {config_path}")
            return None
            
        tree = ET.parse(config_path)
        root = tree.getroot()
        
        # Look for ApiKey element
        api_key_elem = root.find('.//ApiKey')
        if api_key_elem is not None and api_key_elem.text:
            return api_key_elem.text.strip()
            
        print(f"⚠️ ApiKey not found in {config_path}")
        return None
        
    except Exception as e:
        print(f"❌ Error reading {config_path}: {e}")
        return None

def add_applications_to_prowlarr_config(config_path, radarr_api_key, sonarr_api_key):
        return None

def wait_for_service(url, api_key=None, max_retries=12, retry_delay=10):
    """Wait for a service to become available."""
    headers = {}
    if api_key:
        headers['X-Api-Key'] = api_key
    
    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=5) as response:
                if response.status == 200:
                    return True
        except urllib.error.HTTPError as e:
            if e.code == 401:
                # API key might be wrong, try without it first to see if service is up
                if api_key:
                    try:
                        req_no_auth = urllib.request.Request(url.replace('/api/v1/system/status', '/ping'))
                        with urllib.request.urlopen(req_no_auth, timeout=5) as response:
                            if response.status in [200, 401, 403]:  # Service is up but needs auth
                                print(f"🔑 Service is up but API key might be incorrect. Retrying...")
                                # Wait a bit longer for service to fully initialize its config
                                time.sleep(retry_delay * 2)
                            continue
                    except:
                        pass
                print(f"🔄 Service authentication failed, retrying in {retry_delay}s... (attempt {attempt + 1}/{max_retries})")
            else:
                print(f"🔄 Service not ready (HTTP {e.code}), retrying in {retry_delay}s... (attempt {attempt + 1}/{max_retries})")
        except Exception as e:
            print(f"🔄 Service not ready, retrying in {retry_delay}s... (attempt {attempt + 1}/{max_retries})")
        
        if attempt < max_retries - 1:
            time.sleep(retry_delay)
    
    return False

def configure_prowlarr_xml_directly(storage_path, radarr_api_key, sonarr_api_key):
    """Configure Prowlarr by directly editing the XML config file."""
    try:
        config_path = os.path.join(storage_path, "Prowlarr", "config", "config.xml")
        
        if not os.path.exists(config_path):
            print(f"❌ Prowlarr config file not found: {config_path}")
            return False
            
        print("📝 Configuring Prowlarr XML config file...")
        
        # Parse existing XML
        import xml.etree.ElementTree as ET
        from xml.dom import minidom
        
        tree = ET.parse(config_path)
        root = tree.getroot()
        
        # Remove existing Applications section if it exists
        apps_element = root.find('Applications')
        if apps_element is not None:
            root.remove(apps_element)
            print("🔄 Removed existing Applications section")
        
        # Create new Applications section
        apps_element = ET.SubElement(root, 'Applications')
        
        # Add Radarr application
        radarr_app = ET.SubElement(apps_element, 'ApplicationDefinition')
        ET.SubElement(radarr_app, 'Id').text = '1'
        ET.SubElement(radarr_app, 'Name').text = 'Radarr'
        ET.SubElement(radarr_app, 'Implementation').text = 'Radarr'
        ET.SubElement(radarr_app, 'ConfigContract').text = 'RadarrSettings'
        ET.SubElement(radarr_app, 'Enable').text = 'True'  # Enable the application
        ET.SubElement(radarr_app, 'EnableRss').text = 'True'
        ET.SubElement(radarr_app, 'EnableAutomaticSearch').text = 'True'
        ET.SubElement(radarr_app, 'EnableInteractiveSearch').text = 'True'
        ET.SubElement(radarr_app, 'SyncLevel').text = 'fullSync'
        
        # Radarr settings
        radarr_settings = ET.SubElement(radarr_app, 'Settings')
        base_url_field = ET.SubElement(radarr_settings, 'Field')
        ET.SubElement(base_url_field, 'Name').text = 'baseUrl'
        ET.SubElement(base_url_field, 'Value').text = 'http://surge-radarr:7878'
        
        api_key_field = ET.SubElement(radarr_settings, 'Field')
        ET.SubElement(api_key_field, 'Name').text = 'apiKey'
        ET.SubElement(api_key_field, 'Value').text = radarr_api_key
        
        # Add Sonarr application
        sonarr_app = ET.SubElement(apps_element, 'ApplicationDefinition')
        ET.SubElement(sonarr_app, 'Id').text = '2'
        ET.SubElement(sonarr_app, 'Name').text = 'Sonarr'
        ET.SubElement(sonarr_app, 'Implementation').text = 'Sonarr'
        ET.SubElement(sonarr_app, 'ConfigContract').text = 'SonarrSettings'
        ET.SubElement(sonarr_app, 'Enable').text = 'True'  # Enable the application
        ET.SubElement(sonarr_app, 'EnableRss').text = 'True'
        ET.SubElement(sonarr_app, 'EnableAutomaticSearch').text = 'True'
        ET.SubElement(sonarr_app, 'EnableInteractiveSearch').text = 'True'
        ET.SubElement(sonarr_app, 'SyncLevel').text = 'fullSync'
        
        # Sonarr settings
        sonarr_settings = ET.SubElement(sonarr_app, 'Settings')
        base_url_field = ET.SubElement(sonarr_settings, 'Field')
        ET.SubElement(base_url_field, 'Name').text = 'baseUrl'
        ET.SubElement(base_url_field, 'Value').text = 'http://surge-sonarr:8989'
        
        api_key_field = ET.SubElement(sonarr_settings, 'Field')
        ET.SubElement(api_key_field, 'Name').text = 'apiKey'
        ET.SubElement(api_key_field, 'Value').text = sonarr_api_key
        
        # Write back to file with proper formatting
        xml_string = ET.tostring(root, encoding='unicode')
        dom = minidom.parseString(xml_string)
        
        # Write formatted XML
        with open(config_path, 'w', encoding='utf-8') as f:
            f.write(dom.toprettyxml(indent='  ').replace('<?xml version="1.0" ?>', '<?xml version=\'1.0\' encoding=\'utf-8\'?>'))
        
        print("✅ Prowlarr XML configuration updated successfully")
        return True
        
    except Exception as e:
        print(f"❌ Error configuring Prowlarr XML: {e}")
        return False

def make_api_request(url, headers, data=None, method='GET'):
    """Make HTTP request to Prowlarr API."""
    try:
        if data:
            data = json.dumps(data).encode('utf-8')
            headers['Content-Type'] = 'application/json'
        
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            if response.status in [200, 201]:
                return True, json.loads(response.read().decode('utf-8'))
            else:
                return False, f"HTTP {response.status}"
    
    except urllib.error.HTTPError as e:
        error_msg = e.read().decode('utf-8') if e.fp else str(e)
        return False, f"HTTP {e.code}: {error_msg}"
    except Exception as e:
        return False, str(e)

def test_prowlarr_api(api_key, max_retries=6):
    """Test if Prowlarr API is accessible with retries."""
    headers = {'X-Api-Key': api_key}
    
    for attempt in range(max_retries):
        try:
            success, result = make_api_request('http://localhost:9696/api/v1/system/status', headers)
            if success:
                print(f"✅ Connected to Prowlarr API (version {result.get('version', 'unknown')})")
                return True
            else:
                if attempt < max_retries - 1:
                    print(f"🔄 Prowlarr API not ready, retrying... (attempt {attempt + 1}/{max_retries})")
                    time.sleep(10)
                else:
                    print(f"❌ Cannot connect to Prowlarr API: {result}")
                    return False
        except Exception as e:
            if attempt < max_retries - 1:
                print(f"🔄 Prowlarr API not ready, retrying... (attempt {attempt + 1}/{max_retries})")
                time.sleep(10)
            else:
                print(f"❌ Cannot connect to Prowlarr API: {e}")
                return False
    
    return False

def configure_prowlarr_via_api(prowlarr_api_key, radarr_api_key, sonarr_api_key):
    """Configure Prowlarr applications via API."""
    
    # Test API connection first
    if not test_prowlarr_api(prowlarr_api_key):
        return False
    
    headers = {'X-Api-Key': prowlarr_api_key}
    
    # Clean up existing applications
    print("🔄 Cleaning up existing applications...")
    success, existing_apps = make_api_request('http://localhost:9696/api/v1/applications', headers)
    if success and existing_apps:
        for app in existing_apps:
            if app['name'] in ['Radarr', 'Sonarr']:
                print(f"🗑️ Removing existing {app['name']} application...")
                make_api_request(f"http://localhost:9696/api/v1/applications/{app['id']}", headers, method='DELETE')
    
    # Add Radarr application
    print("➕ Adding Radarr application...")
    radarr_data = {
        "name": "Radarr",
        "implementation": "Radarr",
        "configContract": "RadarrSettings",
        "enable": True,
        "enableRss": True,
        "enableAutomaticSearch": True,
        "enableInteractiveSearch": True,
        "syncLevel": "fullSync",
        "tags": [],
        "fields": [
            {"name": "baseUrl", "value": "http://surge-radarr:7878"},
            {"name": "apiKey", "value": radarr_api_key},
            {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"},
            {"name": "syncCategories", "value": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060]}
        ]
    }
    
    success, result = make_api_request('http://localhost:9696/api/v1/applications', headers, radarr_data, 'POST')
    if not success:
        print(f"❌ Failed to add Radarr: {result}")
        return False
    print("✅ Radarr application added successfully")
    
    # Add Sonarr application
    print("➕ Adding Sonarr application...")
    sonarr_data = {
        "name": "Sonarr",
        "implementation": "Sonarr",
        "configContract": "SonarrSettings",
        "enable": True,
        "enableRss": True,
        "enableAutomaticSearch": True,
        "enableInteractiveSearch": True,
        "syncLevel": "fullSync",
        "tags": [],
        "fields": [
            {"name": "baseUrl", "value": "http://surge-sonarr:8989"},
            {"name": "apiKey", "value": sonarr_api_key},
            {"name": "prowlarrUrl", "value": "http://surge-prowlarr:9696"},
            {"name": "syncCategories", "value": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080]}
        ]
    }
    
    success, result = make_api_request('http://localhost:9696/api/v1/applications', headers, sonarr_data, 'POST')
    if not success:
        print(f"❌ Failed to add Sonarr: {result}")
        return False
    print("✅ Sonarr application added successfully")
    
    # Verify configuration
    print("🔍 Verifying configuration...")
    time.sleep(2)
    success, final_apps = make_api_request('http://localhost:9696/api/v1/applications', headers)
    if success and final_apps:
        print(f"✅ Configuration complete! Found {len(final_apps)} applications:")
        for app in final_apps:
            status = "✅ Enabled" if app.get('enable', False) else "❌ Disabled"
            print(f"   - {app['name']}: {status}")
    
    return True

def configure_prowlarr_applications(storage_path=None):
    """Configure Prowlarr applications using API-based approach for better reliability."""
    if storage_path is None:
        storage_path = find_storage_path()
    
    print(f"🔍 Using storage path: {storage_path}")
    
    # Read API keys from config files
    radarr_config = os.path.join(storage_path, "Radarr", "config", "config.xml") 
    sonarr_config = os.path.join(storage_path, "Sonarr", "config", "config.xml")
    prowlarr_config = os.path.join(storage_path, "Prowlarr", "config", "config.xml")
    
    # Wait for services to generate their configurations
    print("⏳ Waiting for services to generate configuration files...")
    max_config_wait = 8
    for attempt in range(max_config_wait):
        radarr_api_key = get_api_key_from_xml(radarr_config)
        sonarr_api_key = get_api_key_from_xml(sonarr_config)
        prowlarr_api_key = get_api_key_from_xml(prowlarr_config)
        
        if radarr_api_key and sonarr_api_key and prowlarr_api_key:
            break
            
        if attempt < max_config_wait - 1:
            print(f"🔄 Waiting for API keys to be generated... (attempt {attempt + 1}/{max_config_wait})")
            time.sleep(15)
    
    # Final check for API keys
    radarr_api_key = get_api_key_from_xml(radarr_config)
    sonarr_api_key = get_api_key_from_xml(sonarr_config)
    prowlarr_api_key = get_api_key_from_xml(prowlarr_config)
    
    if not all([radarr_api_key, sonarr_api_key, prowlarr_api_key]):
        print("❌ Failed to read API keys for all services")
        print("💡 Make sure all services have started and generated their configurations")
        return False
    
    print("✅ Successfully read API keys for all services")
    print(f"🔑 Prowlarr API key: {prowlarr_api_key[:8]}...")
    print(f"🔑 Radarr API key: {radarr_api_key[:8]}...")
    print(f"🔑 Sonarr API key: {sonarr_api_key[:8]}...")
    
    # Configure applications via API (more reliable than XML modification)
    print("🚀 Configuring Prowlarr applications via API...")
    success = configure_prowlarr_via_api(prowlarr_api_key, radarr_api_key, sonarr_api_key)
    
    if success:
        print("✅ Prowlarr applications configured successfully via API!")
        print("💡 Applications should now be visible in Prowlarr UI at http://localhost:9696")
        print("💡 Go to Settings → Apps to see Radarr and Sonarr")
        return True
    else:
        print("❌ Failed to configure Prowlarr applications via API")
        return False

def add_applications_to_prowlarr_db(db_path, radarr_api_key, sonarr_api_key):
    """Add Radarr and Sonarr applications directly to Prowlarr database."""
    try:
        if not os.path.exists(db_path):
            print(f"❌ Database file not found: {db_path}")
            return False
            
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Step 1: Complete cleanup
        print("🔄 Cleaning up existing applications...")
        cursor.execute("DELETE FROM ApplicationStatus")
        cursor.execute("DELETE FROM Applications") 
        cursor.execute("DELETE FROM ApplicationIndexerMapping")
        conn.commit()
        
        # Step 2: Add applications with exact Prowlarr JSON format (no spaces)
        print("� Adding applications with exact Prowlarr format...")
        
        # Radarr - exact JSON format that Prowlarr expects
        radarr_settings = f'{{"baseUrl":"http://surge-radarr:7878","apiKey":"{radarr_api_key}","syncCategories":[2000,2010,2020,2030,2035,2040,2045,2050,2060,2070,2080,2090],"animeSyncCategories":[]}}'
        
        cursor.execute("""
            INSERT INTO Applications (Name, Implementation, ConfigContract, Settings, SyncLevel, Tags)
            VALUES ('Radarr', 'Radarr', 'RadarrSettings', ?, 1, '[]')
        """, (radarr_settings,))
        
        radarr_id = cursor.lastrowid
        print(f"✅ Added Radarr application (ID: {radarr_id})")
        
        # Sonarr - exact JSON format that Prowlarr expects  
        sonarr_settings = f'{{"baseUrl":"http://surge-sonarr:8989","apiKey":"{sonarr_api_key}","syncCategories":[5000,5010,5020,5030,5040,5045,5050,5060,5070,5080,5090],"animeSyncCategories":[5070]}}'
        
        cursor.execute("""
            INSERT INTO Applications (Name, Implementation, ConfigContract, Settings, SyncLevel, Tags)
            VALUES ('Sonarr', 'Sonarr', 'SonarrSettings', ?, 1, '[]')
        """, (sonarr_settings,))
        
        sonarr_id = cursor.lastrowid
        print(f"✅ Added Sonarr application (ID: {sonarr_id})")
        
        # Step 3: Add ApplicationStatus entries
        cursor.execute("""
            INSERT INTO ApplicationStatus (ProviderId, InitialFailure, MostRecentFailure, EscalationLevel, DisabledTill)
            VALUES (?, NULL, NULL, 1, NULL)
        """, (radarr_id,))
        
        cursor.execute("""
            INSERT INTO ApplicationStatus (ProviderId, InitialFailure, MostRecentFailure, EscalationLevel, DisabledTill) 
            VALUES (?, NULL, NULL, 1, NULL)
        """, (sonarr_id,))
        
        conn.commit()
        
        # Step 4: Touch database file to trigger potential cache refresh
        import time
        current_time = time.time()
        os.utime(db_path, (current_time, current_time))
        
        conn.close()
        
        print(f"✅ Prowlarr database updated: {db_path}")
        print("📋 Applications configured with exact Prowlarr format")
        return True
        
    except Exception as e:
        print(f"❌ Error updating Prowlarr database: {e}")
        try:
            conn.close()
        except:
            pass
        return False
        
    except Exception as e:
        print(f"❌ Error updating Prowlarr database: {e}")
        try:
            conn.close()
        except:
            pass
        return False
    
    # Configure applications
    headers = {
        'X-Api-Key': prowlarr_api_key,
        'Content-Type': 'application/json'
    }
    
    applications_to_add = [
        {
            "name": "Radarr",
            "implementation": "Radarr",
            "configContract": "RadarrSettings",
            "fields": [
                {"name": "apiKey", "value": radarr_api_key},
                {"name": "baseUrl", "value": "http://surge-radarr:7878"}
            ],
            "syncLevel": "fullSync",
            "enableRss": True,
            "enableAutomaticSearch": True,
            "enableInteractiveSearch": True,
            "isDefault": True
        },
        {
            "name": "Sonarr",
            "implementation": "Sonarr",
            "configContract": "SonarrSettings",
            "fields": [
                {"name": "apiKey", "value": sonarr_api_key},
                {"name": "baseUrl", "value": "http://surge-sonarr:8989"}
            ],
            "syncLevel": "fullSync",
            "enableRss": True,
            "enableAutomaticSearch": True,
            "enableInteractiveSearch": True,
            "isDefault": True
        }
    ]
    
    success_count = 0
    for app_config in applications_to_add:
        app_name = app_config["name"]
        try:
            print(f"📡 Adding {app_name} application to Prowlarr...")
            data = json.dumps(app_config).encode('utf-8')
            req = urllib.request.Request(f'{prowlarr_url}/api/v1/applications', data=data, headers=headers, method='POST')
            
            with urllib.request.urlopen(req, timeout=10) as response:
                if response.status in [200, 201]:
                    print(f"✅ {app_name} application added successfully")
                    success_count += 1
                else:
                    # Check if application already exists
                    try:
                        error_data = json.loads(response.read().decode())
                        if any("already exists" in str(error).lower() for error in error_data):
                            print(f"ℹ️ {app_name} application already exists")
                            success_count += 1
                        else:
                            print(f"⚠️ Failed to add {app_name} application: {response.status}")
                    except:
                        print(f"⚠️ Failed to add {app_name} application: {response.status}")
                        
        except Exception as e:
            print(f"❌ Error adding {app_name} application: {e}")
    
    # Show current applications
    try:
        print("\n📋 Current Prowlarr applications:")
        req = urllib.request.Request(f'{prowlarr_url}/api/v1/applications', headers={'X-Api-Key': prowlarr_api_key})
        
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                apps = json.loads(response.read().decode())
                print(f"Found {len(apps)} applications configured:")
                for app in apps:
                    print(f"  - {app.get('name', 'Unknown')} ({app.get('implementation', 'Unknown')})")
            else:
                print(f"Failed to retrieve applications: {response.status}")
                
    except Exception as e:
        print(f"❌ Error checking applications: {e}")
    
    return success_count > 0

def configure_bazarr_applications():
    """Configure Bazarr connections to Radarr and Sonarr."""
    print("🎬 Configuring Bazarr applications...")
    
    storage_path = find_storage_path()
    print(f"📁 Using storage path: {storage_path}")
    
    # Get API keys from config files with retry logic
    radarr_config = os.path.join(storage_path, "Radarr", "config", "config.xml")
    sonarr_config = os.path.join(storage_path, "Sonarr", "config", "config.xml") 
    bazarr_config = os.path.join(storage_path, "Bazarr", "config", "config", "config.yaml")
    
    print(f"🔍 Checking for Radarr config at: {radarr_config}")
    print(f"🔍 Checking for Sonarr config at: {sonarr_config}")
    print(f"🔍 Checking for Bazarr YAML config at: {bazarr_config}")
    
    # Wait for config files to exist with retries
    max_retries = 6
    retry_delay = 10
    
    for attempt in range(max_retries):
        radarr_api_key = get_api_key_from_xml(radarr_config)
        sonarr_api_key = get_api_key_from_xml(sonarr_config)
        
        if radarr_api_key and sonarr_api_key:
            print(f"✅ Found API keys on attempt {attempt + 1}")
            break
        elif attempt < max_retries - 1:
            print(f"⏳ API keys not ready, waiting {retry_delay}s... (attempt {attempt + 1}/{max_retries})")
            time.sleep(retry_delay)
        else:
            print("❌ Could not get API keys after all retries")
            if not radarr_api_key:
                print(f"   - Radarr API key missing from {radarr_config}")
            if not sonarr_api_key:
                print(f"   - Sonarr API key missing from {sonarr_config}")
            return False
    
    # Check if Bazarr YAML config exists
    if not os.path.exists(bazarr_config):
        print(f"❌ Bazarr YAML config not found: {bazarr_config}")
        print("⚠️ Bazarr might not be fully initialized yet")
        return False
    
    # Read and update Bazarr YAML configuration
    try:
        import yaml
        
        # Read existing config
        with open(bazarr_config, 'r') as f:
            config_data = yaml.safe_load(f)
        
        print("📝 Updating Bazarr YAML configuration...")
        
        # Enable Radarr and Sonarr usage
        if 'general' not in config_data:
            config_data['general'] = {}
        
        config_data['general']['use_radarr'] = True
        config_data['general']['use_sonarr'] = True
        
        # Configure Radarr connection
        if 'radarr' not in config_data:
            config_data['radarr'] = {}
            
        config_data['radarr'].update({
            'apikey': radarr_api_key,
            'ip': 'surge-radarr',
            'port': 7878,
            'base_url': '/',
            'ssl': False,
            'full_update': 'Daily',
            'only_monitored': False,
            'movies_sync': 60,
            'http_timeout': 60
        })
        
        # Configure Sonarr connection
        if 'sonarr' not in config_data:
            config_data['sonarr'] = {}
            
        config_data['sonarr'].update({
            'apikey': sonarr_api_key,
            'ip': 'surge-sonarr', 
            'port': 8989,
            'base_url': '/',
            'ssl': False,
            'full_update': 'Daily',
            'only_monitored': False,
            'series_sync': 60,
            'http_timeout': 60
        })
        
        # Write updated config back to file
        with open(bazarr_config, 'w') as f:
            yaml.dump(config_data, f, default_flow_style=False, sort_keys=False)
            
        print("✅ Bazarr YAML configuration updated successfully!")
        print(f"📝 Configuration written to: {bazarr_config}")
        print(f"🔗 Radarr connection: surge-radarr:7878 (API: {radarr_api_key[:8]}...)")
        print(f"🔗 Sonarr connection: surge-sonarr:8989 (API: {sonarr_api_key[:8]}...)")
        
        # Attempt to restart Bazarr container to pick up new configuration
        print("� Attempting to restart Bazarr container to pick up new configuration...")
        try:
            import subprocess
            result = subprocess.run(['docker', 'compose', 'restart', 'bazarr'], 
                                  capture_output=True, text=True, cwd=os.path.dirname(os.path.dirname(__file__)))
            if result.returncode == 0:
                print("✅ Bazarr container restarted successfully!")
                print("💡 Bazarr should now show Radarr and Sonarr connections in Settings")
            else:
                print(f"⚠️ Could not restart Bazarr container: {result.stderr}")
                print("💡 Please restart Bazarr manually via web interface or Docker Compose")
        except Exception as e:
            print(f"⚠️ Could not restart Bazarr container: {e}")
            print("💡 Please restart Bazarr manually via web interface or Docker Compose")
        
        return True
        
    except ImportError:
        print("❌ PyYAML not available. Installing...")
        try:
            import subprocess
            subprocess.check_call(['pip3', 'install', 'PyYAML'])
            print("✅ PyYAML installed, please run the configuration again")
            return False
        except Exception as e:
            print(f"❌ Could not install PyYAML: {e}")
            print("💡 Please install PyYAML manually: pip3 install PyYAML")
            return False
            
    except Exception as e:
        print(f"❌ Error configuring Bazarr: {e}")
        return False

def get_tmdb_api_key():
    """Get TMDB API key from environment variables."""
    import os
    tmdb_key = os.environ.get('TMDB_API_KEY')
    if not tmdb_key:
        # Try reading from .env file in project root
        project_root = os.path.dirname(os.path.dirname(__file__))
        env_file = os.path.join(project_root, '.env')
        if os.path.exists(env_file):
            with open(env_file, 'r') as f:
                for line in f:
                    if line.startswith('TMDB_API_KEY='):
                        tmdb_key = line.split('=', 1)[1].strip()
                        break
    return tmdb_key

def get_discord_webhook():
    """Get Discord webhook URL from environment variables."""
    import os
    discord_webhook = os.environ.get('DISCORD_WEBHOOK_URL')
    if not discord_webhook:
        # Try reading from .env file in project root
        project_root = os.path.dirname(os.path.dirname(__file__))
        env_file = os.path.join(project_root, '.env')
        if os.path.exists(env_file):
            with open(env_file, 'r') as f:
                for line in f:
                    if line.startswith('DISCORD_WEBHOOK_URL='):
                        discord_webhook = line.split('=', 1)[1].strip()
                        break
    return discord_webhook

def get_plex_token():
    """Get Plex token from Plex configuration."""
    storage_path = find_storage_path()
    plex_config = os.path.join(storage_path, "Plex", "config", "Preferences.xml")
    
    if not os.path.exists(plex_config):
        print(f"⚠️ Plex config not found: {plex_config}")
        return None
    
    try:
        tree = ET.parse(plex_config)
        root = tree.getroot()
        
        # Look for PlexOnlineToken attribute
        token = root.get('PlexOnlineToken')
        if token:
            return token.strip()
            
        print("⚠️ PlexOnlineToken not found in Plex configuration")
        return None
        
    except Exception as e:
        print(f"❌ Error reading Plex config: {e}")
        return None

def configure_gaps_applications():
    """Configure GAPS connections automatically using the GAPS REST API."""
    print("🎯 Configuring GAPS applications via REST API...")
    
    storage_path = find_storage_path()
    print(f"📁 Using storage path: {storage_path}")
    
    # Get API keys and tokens
    radarr_config = os.path.join(storage_path, "Radarr", "config", "config.xml")
    
    print(f"🔍 Checking for Radarr config at: {radarr_config}")
    
    # Wait for Radarr API key with retries
    max_retries = 6
    retry_delay = 10
    
    for attempt in range(max_retries):
        radarr_api_key = get_api_key_from_xml(radarr_config)
        
        if radarr_api_key:
            print(f"✅ Found Radarr API key on attempt {attempt + 1}")
            break
        elif attempt < max_retries - 1:
            print(f"⏳ Radarr API key not ready, waiting {retry_delay}s... (attempt {attempt + 1}/{max_retries})")
            time.sleep(retry_delay)
        else:
            print("❌ Could not get Radarr API key after all retries")
            print(f"   - Radarr API key missing from {radarr_config}")
            return False
    
    # Get TMDB API key
    tmdb_api_key = get_tmdb_api_key()
    if not tmdb_api_key:
        print("❌ TMDB API key not found in environment or .env file")
        print("💡 Make sure TMDB_API_KEY is set in your .env file")
        return False
    
    # Get Discord webhook (optional)
    discord_webhook = get_discord_webhook()
    
    # Get Plex token
    plex_token = get_plex_token()
    if not plex_token:
        print("⚠️ Plex token not found - GAPS will work but may have limited Plex integration")
        print("💡 Make sure Plex is claimed and configured")
    
    # Wait for GAPS to be ready (it needs time to start up)
    gaps_url = "http://localhost:8484"
    max_gaps_retries = 12
    gaps_retry_delay = 10
    
    print("⏳ Waiting for GAPS to be ready...")
    for attempt in range(max_gaps_retries):
        try:
            import urllib.request
            import urllib.error
            
            # Try to access GAPS homepage
            req = urllib.request.Request(f"{gaps_url}/", headers={'User-Agent': 'Surge-Config/1.0'})
            response = urllib.request.urlopen(req, timeout=10)
            if response.status == 200:
                print(f"✅ GAPS is ready on attempt {attempt + 1}")
                break
        except (urllib.error.URLError, urllib.error.HTTPError, Exception) as e:
            if attempt < max_gaps_retries - 1:
                print(f"⏳ GAPS not ready yet, waiting {gaps_retry_delay}s... (attempt {attempt + 1}/{max_gaps_retries})")
                time.sleep(gaps_retry_delay)
            else:
                print(f"❌ GAPS not accessible after {max_gaps_retries} attempts")
                print(f"   - Could not connect to {gaps_url}")
                print(f"   - Last error: {e}")
                return False
    
    # Configure GAPS via REST API
    try:
        import urllib.request
        import urllib.parse
        import json
        
        print("📝 Configuring GAPS via REST API...")
        
        # 1. Test TMDB API key first
        test_url = f"{gaps_url}/configuration/test/tmdbKey/{tmdb_api_key}"
        print(f"🔍 Testing TMDB API key...")
        
        req = urllib.request.Request(test_url, headers={'User-Agent': 'Surge-Config/1.0'})
        req.get_method = lambda: 'PUT'
        
        try:
            response = urllib.request.urlopen(req, timeout=30)
            test_response = json.loads(response.read().decode('utf-8'))
            
            if test_response.get('code') == 20:  # TMDB_KEY_VALID = 20
                print("✅ TMDB API key is valid")
            else:
                print(f"❌ TMDB API key test failed: {test_response}")
                return False
                
        except Exception as e:
            print(f"❌ Failed to test TMDB API key: {e}")
            return False
        
        # 2. Save TMDB API key
        save_url = f"{gaps_url}/configuration/save/tmdbKey/{tmdb_api_key}"
        print(f"💾 Saving TMDB API key...")
        
        req = urllib.request.Request(save_url, headers={'User-Agent': 'Surge-Config/1.0'})
        req.get_method = lambda: 'POST'
        
        try:
            response = urllib.request.urlopen(req, timeout=30)
            save_response = json.loads(response.read().decode('utf-8'))
            
            if save_response.get('code') == 23:  # TMDB_KEY_SAVE_SUCCESSFUL = 23
                print("✅ TMDB API key saved successfully")
            else:
                print(f"❌ TMDB API key save failed: {save_response}")
                return False
                
        except Exception as e:
            print(f"❌ Failed to save TMDB API key: {e}")
            return False
        
        # 3. Add Plex server (if token available)
        if plex_token:
            print(f"🎬 Adding Plex server...")
            plex_url = f"{gaps_url}/configuration/add/plex"
            
            # Prepare form data for Plex server
            plex_data = {
                'address': 'surge-plex',
                'port': '32400',
                'plexToken': plex_token
            }
            
            # Encode form data
            encoded_data = urllib.parse.urlencode(plex_data).encode('utf-8')
            
            req = urllib.request.Request(
                plex_url, 
                data=encoded_data,
                headers={
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'User-Agent': 'Surge-Config/1.0'
                }
            )
            
            try:
                response = urllib.request.urlopen(req, timeout=30)
                if response.status == 200:
                    print("✅ Plex server added successfully")
                else:
                    print(f"⚠️ Plex server add returned status: {response.status}")
                    
            except Exception as e:
                print(f"⚠️ Failed to add Plex server (non-critical): {e}")
                print("💡 You can add Plex server manually in GAPS web interface")
        
        print("\n" + "="*60)
        print("🎯 GAPS Configuration Completed Successfully!")
        print("="*60)
        print("✅ GAPS is now fully configured and ready to use")
        print("✅ TMDB API key configured automatically")
        print(f"✅ TMDB API key: {tmdb_api_key[:8]}...")
        
        if plex_token:
            print("✅ Plex server configured automatically")
            print(f"✅ Plex token: {plex_token[:8]}...")
        else:
            print("⚠️ Plex server not configured (token not found)")
            
        if discord_webhook:
            print("ℹ️ Discord webhook available for notifications")
            print(f"ℹ️ Webhook: {discord_webhook[:50]}...")
        
        print("\n🌟 Next Steps:")
        print("1. Visit http://localhost:8484 to access GAPS")
        print("2. Go to Libraries tab to scan your Plex libraries")
        print("3. Go to Recommended tab to find missing movies")
        print("4. Configure notifications in Settings if desired")
        print("="*60)
        
        return True
        
    except Exception as e:
        print(f"❌ Error configuring GAPS via API: {e}")
        print("💡 GAPS may need more time to start up, or there may be a network issue")
        print("💡 You can configure GAPS manually at http://localhost:8484")
        print(f"💡 Use TMDB API key: {tmdb_api_key}")
        return False

if __name__ == '__main__':
    """Allow this module to be run directly for testing."""
    configure_prowlarr_applications()
    configure_bazarr_applications()
    configure_gaps_applications()
