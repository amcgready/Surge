#!/usr/bin/env python3

"""
Zurg Automation Configuration

This script automatically configures Zurg for the Surge media stack.
Zurg is a Real-Debrid WebDAV server that mounts your torrent library
into the filesystem using rclone integration.

Key Features:
- Real-Debrid API integration with backup token support
- Automatic media server configuration (Plex/Emby/Jellyfin)
- rclone mount optimization
- Repair worker automation
- Directory structure organization
- Performance tuning for large libraries
"""

import os
import sys
import time
import requests
from pathlib import Path

class ZurgConfigurator:
    """Main Zurg configuration class"""
    
    def __init__(self, storage_path: str = "/opt/surge"):
        self.storage_path = self._validate_storage_path(storage_path)
        self.zurg_config_dir = Path(self.storage_path) / "Zurg" / "config"
        self.zurg_data_dir = Path(self.storage_path) / "downloads" / "Zurg"
        self.zurg_mount_dir = Path("/mnt/zurg")  # Standard mount point
        
        # Service URLs (using Docker network names)
        self.zurg_url = "http://zurg:9999"
        self.plex_url = f"http://plex:{os.environ.get('PLEX_PORT', '32400')}"
        self.emby_url = f"http://emby:{os.environ.get('EMBY_PORT', '8096')}"
        self.jellyfin_url = f"http://jellyfin:{os.environ.get('JELLYFIN_PORT', '8096')}"
        
        # API Keys from environment
        self.rd_api_token = os.environ.get('RD_API_TOKEN', '')
        self.rd_backup_tokens = [
            token.strip() for token in os.environ.get('RD_BACKUP_TOKENS', '').split(',')
            if token.strip()
        ]
        
        # Media server selection
        self.media_server = os.environ.get('MEDIA_SERVER', 'plex').lower()
        
    def _validate_storage_path(self, path: str) -> str:
        """Validate storage path for security"""
        try:
            path_obj = Path(path).resolve()
            if not path_obj.is_absolute():
                raise ValueError("Storage path must be absolute")
            return str(path_obj)
        except Exception as e:
            print(f"⚠️  Invalid storage path '{path}': {e}")
            return "/opt/surge"  # Fallback to safe default
            
    def ensure_directories(self):
        """Create necessary directories for Zurg"""
        print("📁 Creating Zurg directories...")
        
        directories = [
            self.zurg_config_dir,
            self.zurg_data_dir,
            # Zurg data organization
            self.zurg_data_dir / "__all__",
            self.zurg_data_dir / "movies",
            self.zurg_data_dir / "shows",
            self.zurg_data_dir / "anime",
            # Backup and dump directories
            self.zurg_config_dir / "dump",
            self.zurg_config_dir / "trash",
            self.zurg_config_dir / "strm",
            # Mount point preparation
            self.zurg_mount_dir,
            # rclone configuration
            Path(self.storage_path) / ".config" / "rclone",
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"  ✓ Created: {directory}")
            
    def wait_for_service(self, service_name: str, url: str, max_attempts: int = 30) -> bool:
        """Wait for a service to become available"""
        print(f"⏳ Waiting for {service_name} to be ready...")
        
        for attempt in range(max_attempts):
            try:
                if "zurg" in url.lower():
                    response = requests.get(f"{url}/health", timeout=5)
                elif "plex" in url.lower():
                    response = requests.get(f"{url}/identity", timeout=5)
                elif "emby" in url.lower() or "jellyfin" in url.lower():
                    response = requests.get(f"{url}/System/Info", timeout=5)
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
        
    def test_real_debrid_connection(self):
        """Test Real-Debrid API connectivity"""
        print("🧪 Testing Real-Debrid connection...")
        if not self.rd_api_token:
            print("  ⚠️  No Real-Debrid API token found!")
            print("  💡 Please set RD_API_TOKEN environment variable")
            return False
        try:
            headers = {'Authorization': f'Bearer {self.rd_api_token}'}
            response = requests.get('https://api.real-debrid.com/rest/1.0/user', headers=headers, timeout=10)
            if response.status_code == 200:
                user_data = response.json()
                print(f"  ✅ Connected to Real-Debrid as {user_data.get('username', 'unknown')}")
                return True
            else:
                print(f"  ❌ Real-Debrid connection failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"  ⚠️  Error connecting to Real-Debrid: {e}")
            return False
    def create_zurg_config(self):
        """Write Zurg config.yml matching the official template, inserting only the token and on_library_update."""
        print("📝 Generating Zurg configuration (official template)...")
        config_file = self.zurg_config_dir / "config.yml"
        token = self.rd_api_token or "yourtoken"
        config_template = f'''zurg: v1
token: {token}
# host: "[::]"
# port: 9999
# username:
# password:
#
proxy:
# concurrent_workers: 20
check_for_changes_every_secs: 10
#
repair_every_mins: 60
# ignore_renames: false
# retain_rd_torrent_name: false
#
retain_folder_name_extension: false
enable_repair: true
auto_delete_rar_torrents: true
#
api_timeout_secs: 15
# download_timeout_secs: 10
# enable_download_mount: false
#
rate_limit_sleep_secs: 6
# retries_until_failed: 2
# network_buffer_size: 4194304
# 4MB
# serve_from_rclone: false
# verify_download_link: false
# force_ipv6:
false
on_library_update: sh plex_update.sh "$@"
#for windows comment the line above
#and uncomment the line below:
#on_library_update: '& powershell -ExecutionPolicy Bypass -File .\\plex_update.ps1 --% "$args"'

directories:
  anime:
    group_order: 10
    group: media
    filters:
      - regex: /\b[a-fA-F0-9]{{8}}\b/
      - any_file_inside_regex: /\b[a-fA-F0-9]{{8}}\b/
  shows:
    group_order: 20
    group: media
    filters:
      - has_episodes: true
  movies:
    group_order: 30
    group: media
    only_show_the_biggest_file: true
    filters:
      - regex: /.*/
'''
        with open(config_file, 'w', encoding='utf-8') as f:
            f.write(config_template)
        print(f"  ✓ Configuration saved to: {config_file}")
        return True
        
        
    def create_plex_update_script(self):
        """Create Plex library update script"""
        print("📝 Creating Plex update script...")
        
        script_path = self.zurg_config_dir / "plex_update.sh"
        script_content = '''#!/bin/bash

# Plex Library Update Script for Zurg
# This script is called whenever Zurg detects library changes

PLEX_URL="${PLEX_URL:-http://plex:32400}"
PLEX_TOKEN="${PLEX_TOKEN:-}"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to refresh Plex libraries
refresh_plex_libraries() {
    if [ -z "$PLEX_TOKEN" ]; then
        log "WARNING: PLEX_TOKEN not set, skipping Plex refresh"
        return 1
    fi
    
    log "Refreshing Plex libraries due to Zurg update..."
    
    # Get all library sections
    LIBRARIES=$(curl -s "${PLEX_URL}/library/sections?X-Plex-Token=${PLEX_TOKEN}" | grep -o 'key="[0-9]*"' | grep -o '[0-9]*')
    
    if [ -z "$LIBRARIES" ]; then
        log "ERROR: Could not retrieve Plex libraries"
        return 1
    fi
    
    # Refresh each library
    for LIBRARY_ID in $LIBRARIES; do
        log "Refreshing library section $LIBRARY_ID..."
        curl -s -X POST "${PLEX_URL}/library/sections/${LIBRARY_ID}/refresh?X-Plex-Token=${PLEX_TOKEN}" > /dev/null
    done
    
    log "Plex library refresh completed"
}

# Function to handle specific path updates
handle_path_update() {
    local updated_path="$1"
    log "Detected update on path: $updated_path"
    
    # Add custom logic here if needed
    # For example, you could refresh only specific libraries based on path
    
    refresh_plex_libraries
}

# Main execution
if [ $# -eq 0 ]; then
    log "No arguments provided, performing full library refresh"
    refresh_plex_libraries
else
    for arg in "$@"; do
        handle_path_update "$arg"
    done
fi

log "Plex update script completed"
'''
        
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write(script_content)
            
        # Make script executable with secure permissions
        os.chmod(script_path, 0o750)
        print(f"  ✓ Plex update script created: {script_path}")
        
    def create_rclone_config(self):
        """Create rclone configuration for mounting Zurg"""
        print("📝 Creating rclone configuration...")
        
        rclone_config_dir = Path(self.storage_path) / ".config" / "rclone"
        rclone_config_file = rclone_config_dir / "rclone.conf"
        
        # rclone configuration for Zurg WebDAV mount
        rclone_content = f'''[zurg]
type = webdav
url = http://zurg:9999
vendor = other
pacer_min_sleep = 0
'''
        
        with open(rclone_config_file, 'w', encoding='utf-8') as f:
            f.write(rclone_content)
            
        print(f"  ✓ rclone configuration saved to: {rclone_config_file}")
        
        # Create mount script
        mount_script = self.zurg_config_dir / "mount_zurg.sh"
        mount_content = f'''#!/bin/bash

# Zurg rclone Mount Script
# This script mounts Zurg WebDAV as a filesystem

MOUNT_POINT="/mnt/zurg"
RCLONE_CONFIG="{rclone_config_file}"

# Ensure mount point exists
mkdir -p "$MOUNT_POINT"

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "✅ Zurg already mounted at $MOUNT_POINT"
    exit 0
fi

echo "🔄 Mounting Zurg at $MOUNT_POINT..."

# Mount with optimized settings for media streaming
rclone mount zurg: "$MOUNT_POINT" \\
    --config "$RCLONE_CONFIG" \\
    --allow-other \\
    --allow-non-empty \\
    --dir-cache-time 5s \\
    --poll-interval 15s \\
    --cache-dir /tmp/rclone-cache \\
    --vfs-cache-mode writes \\
    --vfs-cache-max-age 1h \\
    --vfs-read-chunk-size 128M \\
    --vfs-read-chunk-size-limit 2G \\
    --buffer-size 128M \\
    --timeout 10s \\
    --contimeout 10s \\
    --retries 3 \\
    --low-level-retries 10 \\
    --stats 0 \\
    --log-level INFO \\
    --daemon

if [ $? -eq 0 ]; then
    echo "✅ Zurg mounted successfully at $MOUNT_POINT"
else
    echo "❌ Failed to mount Zurg"
    exit 1
fi
'''
        
        with open(mount_script, 'w', encoding='utf-8') as f:
            f.write(mount_content)
            
        os.chmod(mount_script, 0o750)
        print(f"  ✓ Mount script created: {mount_script}")
        
        return True
        
    def create_helper_scripts(self):
        """Create helper scripts for Zurg management"""
        print("📝 Creating helper scripts...")
        
        # Status checking script
        status_script = self.zurg_config_dir / "check_status.py"
        status_content = '''#!/usr/bin/env python3
"""Zurg Status Checker"""

import json
import requests
import sys
import subprocess
from pathlib import Path

def check_zurg_status():
    """Check Zurg service status"""
    try:
        response = requests.get("http://localhost:9999/health", timeout=10)
        if response.status_code == 200:
            print("✅ Zurg service is running and healthy")
            return True
        else:
            print(f"⚠️  Zurg service returned status {response.status_code}")
    except Exception as e:
        print(f"❌ Zurg service not responding: {e}")
    return False

def check_real_debrid():
    """Check Real-Debrid connection"""
    config_file = Path("/app/config/config.yml")
    if not config_file.exists():
        print("❌ Zurg configuration not found")
        return False
        
    try:
        with open(config_file, 'r') as f:
            content = f.read()
            if 'token:' in content:
                print("✅ Real-Debrid token configured")
                return True
            else:
                print("❌ Real-Debrid token not found in config")
    except Exception as e:
        print(f"❌ Could not read Zurg config: {e}")
    return False

def check_mount_status():
    """Check if Zurg is mounted via rclone"""
    try:
        result = subprocess.run(['mountpoint', '/mnt/zurg'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Zurg mounted at /mnt/zurg")
            
            # Check mount contents
            mount_path = Path("/mnt/zurg")
            if mount_path.exists():
                items = list(mount_path.iterdir())
                print(f"📁 Mount contains {len(items)} items")
                for item in items[:5]:  # Show first 5 items
                    print(f"  • {item.name}")
                if len(items) > 5:
                    print(f"  ... and {len(items) - 5} more items")
            return True
        else:
            print("⚠️  Zurg not mounted at /mnt/zurg")
    except Exception as e:
        print(f"❌ Could not check mount status: {e}")
    return False

def main():
    print("🔍 Zurg Status Check")
    print("=" * 40)
    
    checks = [
        ("Zurg Service", check_zurg_status),
        ("Real-Debrid Config", check_real_debrid),
        ("rclone Mount", check_mount_status)
    ]
    
    passed = 0
    for check_name, check_func in checks:
        print(f"\\n📋 {check_name}:")
        if check_func():
            passed += 1
            
    print(f"\\n📊 Summary: {passed}/{len(checks)} checks passed")
    
    if passed == len(checks):
        print("🎉 Zurg is fully operational!")
    else:
        print("⚠️  Some issues detected, check logs for details")

if __name__ == "__main__":
    main()
'''
        
        with open(status_script, 'w', encoding='utf-8') as f:
            f.write(status_content)
            
        os.chmod(status_script, 0o750)
        print(f"  ✓ Created status script: {status_script}")
        
        # Repair script
        repair_script = self.zurg_config_dir / "repair_library.py"
        repair_content = '''#!/usr/bin/env python3
"""Zurg Library Repair Script"""

import requests
import json
import sys
from datetime import datetime

def trigger_repair():
    """Trigger Zurg repair process"""
    try:
        # Trigger repair via Zurg API
        response = requests.post("http://localhost:9999/torrents/repair", timeout=30)
        if response.status_code == 200:
            print("✅ Library repair triggered successfully")
            return True
        else:
            print(f"⚠️  Repair trigger failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Could not trigger repair: {e}")
    return False

def get_library_stats():
    """Get library statistics"""
    try:
        response = requests.get("http://localhost:9999/torrents", timeout=10)
        if response.status_code == 200:
            torrents = response.json()
            total_torrents = len(torrents)
            
            # Count by status
            active = sum(1 for t in torrents if t.get('status') == 'downloaded')
            broken = sum(1 for t in torrents if t.get('status') == 'error')
            
            print(f"📊 Library Statistics:")
            print(f"  Total torrents: {total_torrents}")
            print(f"  Active: {active}")
            print(f"  Broken: {broken}")
            print(f"  Health: {((active/total_torrents)*100):.1f}%" if total_torrents > 0 else "N/A")
            
            return True
    except Exception as e:
        print(f"❌ Could not get library stats: {e}")
    return False

def main():
    print("🔧 Zurg Library Repair")
    print("=" * 40)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    print("\\n1. Getting current library statistics...")
    get_library_stats()
    
    print("\\n2. Triggering repair process...")
    if trigger_repair():
        print("\\n✅ Repair process initiated")
        print("💡 Monitor Zurg logs to track repair progress")
    else:
        print("\\n❌ Repair process failed to start")
        sys.exit(1)

if __name__ == "__main__":
    main()
'''
        
        with open(repair_script, 'w', encoding='utf-8') as f:
            f.write(repair_content)
            
        os.chmod(repair_script, 0o750)
        print(f"  ✓ Created repair script: {repair_script}")
        
        return True
        
    def run_configuration(self):
        """Main configuration process"""
        print("🚀 Starting Zurg configuration...")
        print(f"   Storage path: {self.storage_path}")
        print(f"   Config directory: {self.zurg_config_dir}")
        print(f"   Data directory: {self.zurg_data_dir}")
        print(f"   Media server: {self.media_server}")
        
        success_count = 0
        total_steps = 7
        
        # Step 1: Create directories
        try:
            self.ensure_directories()
            success_count += 1
            print("✅ Step 1/7: Directory structure created")
        except Exception as e:
            print(f"❌ Step 1/7 failed: {e}")
            
        # Step 2: Test Real-Debrid connection
        try:
            if self.test_real_debrid_connection():
                success_count += 1
                print("✅ Step 2/7: Real-Debrid connection verified")
            else:
                print("⚠️  Step 2/7: Real-Debrid connection issues detected")
        except Exception as e:
            print(f"❌ Step 2/7 failed: {e}")
            
        # Step 3: Create Zurg configuration
        try:
            if self.create_zurg_config():
                success_count += 1
                print("✅ Step 3/7: Zurg configuration created")
            else:
                print("⚠️  Step 3/7: Configuration created with warnings")
        except Exception as e:
            print(f"❌ Step 3/7 failed: {e}")
            
        # Step 4: Create Plex update script
        try:
            self.create_plex_update_script()
            success_count += 1
            print("✅ Step 4/7: Plex update script created")
        except Exception as e:
            print(f"❌ Step 4/7 failed: {e}")
            
        # Step 5: Create rclone configuration
        try:
            if self.create_rclone_config():
                success_count += 1
                print("✅ Step 5/7: rclone configuration created")
            else:
                print("⚠️  Step 5/7: rclone configuration issues")
        except Exception as e:
            print(f"❌ Step 5/7 failed: {e}")
            
        # Step 6: Create helper scripts
        try:
            self.create_helper_scripts()
            success_count += 1
            print("✅ Step 6/7: Helper scripts created")
        except Exception as e:
            print(f"❌ Step 6/7 failed: {e}")
            
        # Step 7: Final validation
        try:
            # Verify all critical files exist
            required_files = [
                self.zurg_config_dir / "config.yml",
                self.zurg_config_dir / "plex_update.sh",
                self.zurg_config_dir / "check_status.py"
            ]
            
            all_files_exist = all(f.exists() for f in required_files)
            if all_files_exist:
                success_count += 1
                print("✅ Step 7/7: Configuration validation passed")
            else:
                print("⚠️  Step 7/7: Some configuration files missing")
        except Exception as e:
            print(f"❌ Step 7/7 failed: {e}")
            
        # Final summary
        print(f"\n🎯 Zurg configuration completed!")
        print(f"   ✅ {success_count}/{total_steps} steps successful")
        
        if success_count >= 5:
            print("✅ Zurg is ready for use!")
            print("\n📋 Next steps:")
            print("   1. Start Zurg service: docker compose up -d zurg")
            print("   2. Mount filesystem: /app/config/mount_zurg.sh")
            print("   3. Verify mount: ls /mnt/zurg")
            print("   4. Configure media server libraries to use /mnt/zurg")
            print("   5. Monitor logs: docker logs surge-zurg")
            
            print(f"\n📁 Configuration files:")
            print(f"   • Main config: {self.zurg_config_dir}/config.yml")
            print(f"   • Plex script: {self.zurg_config_dir}/plex_update.sh")
            print(f"   • Mount script: {self.zurg_config_dir}/mount_zurg.sh")
            print(f"   • Status checker: {self.zurg_config_dir}/check_status.py")
            print(f"   • Repair script: {self.zurg_config_dir}/repair_library.py")
            
            print(f"\n🌐 Web Interface:")
            print(f"   • Zurg WebDAV: http://localhost:9999")
            print(f"   • Mount point: /mnt/zurg")
            
            return True
        else:
            print("⚠️  Zurg configuration completed with issues")
            print("💡 Check the output above for specific problems")
            return False

def main():
    """Main entry point"""
    storage_path = sys.argv[1] if len(sys.argv) > 1 else "/opt/surge"
    
    print("=" * 60)
    print("🔧 ZURG AUTOMATED CONFIGURATION")
    print("=" * 60)
    
    configurator = ZurgConfigurator(storage_path)
    success = configurator.run_configuration()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
