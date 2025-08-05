#!/usr/bin/env python3

"""
Surge Container Update Monitor
Continuously monitors for container updates and sends Discord notifications
"""

import asyncio
import json
import os
import sys
import logging
from datetime import datetime
from pathlib import Path
import subprocess

# Try to import requests, handle gracefully if not available
try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False
    print("Warning: 'requests' module not available. Discord notifications will be disabled.")
    print("Install with: pip install requests")

# Setup logging
log_file = os.getenv('SURGE_LOG_FILE', '/var/log/surge-update-monitor.log')
handlers = [logging.StreamHandler()]

# Try to add file handler if possible
try:
    # Create log directory if it doesn't exist and we have permissions
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    handlers.append(logging.FileHandler(log_file))
except (PermissionError, OSError):
    # Fall back to console only logging
    print(f"Warning: Cannot write to {log_file}, using console logging only")

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=handlers
)
logger = logging.getLogger(__name__)

class UpdateMonitor:
    def __init__(self):
        self.project_dir = Path(__file__).parent.parent
        self.compose_file = self.project_dir / "docker-compose.yml"
        self.last_check = None
        self.check_interval = int(os.getenv('UPDATE_CHECK_INTERVAL', '3600'))  # 1 hour default
        self.discord_webhook = os.getenv('DISCORD_WEBHOOK_URL')
        self.notification_enabled = os.getenv('UPDATE_NOTIFICATIONS', 'true').lower() == 'true'
        
        # Load current image digests
        self.current_images = {}
        self.load_current_images()
    
    def load_current_images(self):
        """Load current running container image digests"""
        try:
            result = subprocess.run([
                'docker', 'compose', '-f', str(self.compose_file), 'images', '--format', 'json'
            ], capture_output=True, text=True, cwd=self.project_dir)
            
            if result.returncode == 0:
                for line in result.stdout.strip().split('\n'):
                    if line:
                        image_info = json.loads(line)
                        service = image_info.get('Service')
                        repository = image_info.get('Repository')
                        tag = image_info.get('Tag', 'latest')
                        image_id = image_info.get('ID')
                        
                        if service and repository:
                            self.current_images[service] = {
                                'repository': repository,
                                'tag': tag,
                                'image_id': image_id,
                                'full_name': f"{repository}:{tag}"
                            }
            
            logger.info(f"Loaded {len(self.current_images)} current images")
            
        except Exception as e:
            logger.error(f"Failed to load current images: {e}")
    
    async def check_for_updates(self):
        """Check for available container updates"""
        updates_available = []
        
        try:
            # Pull latest images to check for updates
            logger.info("Checking for container updates...")
            
            result = subprocess.run([
                'docker', 'compose', '-f', str(self.compose_file), 'pull', '--dry-run'
            ], capture_output=True, text=True, cwd=self.project_dir)
            
            # If dry-run isn't supported, do actual pull but track changes
            if "unknown flag" in result.stderr:
                # Get current image IDs before pull
                before_pull = self.get_image_ids()
                
                # Pull latest images
                pull_result = subprocess.run([
                    'docker', 'compose', '-f', str(self.compose_file), 'pull'
                ], capture_output=True, text=True, cwd=self.project_dir)
                
                if pull_result.returncode == 0:
                    # Get image IDs after pull
                    after_pull = self.get_image_ids()
                    
                    # Compare for changes
                    for service, before_id in before_pull.items():
                        after_id = after_pull.get(service)
                        if after_id and before_id != after_id:
                            updates_available.append({
                                'service': service,
                                'image': self.current_images.get(service, {}).get('full_name', 'unknown'),
                                'old_id': before_id[:12],
                                'new_id': after_id[:12]
                            })
            
            # Also check using docker images for additional verification
            if not updates_available:
                updates_available = await self.check_registry_updates()
            
            return updates_available
            
        except Exception as e:
            logger.error(f"Error checking for updates: {e}")
            return []
    
    def get_image_ids(self):
        """Get current image IDs for all services"""
        image_ids = {}
        try:
            result = subprocess.run([
                'docker', 'compose', '-f', str(self.compose_file), 'images', '--format', 'json'
            ], capture_output=True, text=True, cwd=self.project_dir)
            
            if result.returncode == 0:
                for line in result.stdout.strip().split('\n'):
                    if line:
                        image_info = json.loads(line)
                        service = image_info.get('Service')
                        image_id = image_info.get('ID')
                        if service and image_id:
                            image_ids[service] = image_id
            
        except Exception as e:
            logger.error(f"Error getting image IDs: {e}")
        
        return image_ids
    
    async def check_registry_updates(self):
        """Check registry for newer images (alternative method)"""
        updates = []
        
        for service, image_info in self.current_images.items():
            try:
                repository = image_info['repository']
                tag = image_info['tag']
                
                # Check if image has updates using docker manifest
                result = subprocess.run([
                    'docker', 'manifest', 'inspect', f"{repository}:{tag}"
                ], capture_output=True, text=True)
                
                if result.returncode == 0:
                    manifest = json.loads(result.stdout)
                    remote_digest = manifest.get('config', {}).get('digest', '')
                    
                    # Get local image digest
                    inspect_result = subprocess.run([
                        'docker', 'image', 'inspect', image_info['image_id']
                    ], capture_output=True, text=True)
                    
                    if inspect_result.returncode == 0:
                        local_info = json.loads(inspect_result.stdout)[0]
                        local_digest = local_info.get('RepoDigests', [''])[0].split('@')[-1] if local_info.get('RepoDigests') else ''
                        
                        if remote_digest and local_digest and remote_digest != local_digest:
                            updates.append({
                                'service': service,
                                'image': image_info['full_name'],
                                'local_digest': local_digest[:12],
                                'remote_digest': remote_digest[:12]
                            })
                
            except Exception as e:
                logger.debug(f"Could not check registry for {service}: {e}")
                continue
        
        return updates
    
    async def send_discord_notification(self, updates):
        """Send Discord notification about available updates"""
        if not self.discord_webhook or not self.notification_enabled or not REQUESTS_AVAILABLE:
            if not REQUESTS_AVAILABLE:
                logger.warning("Discord notifications disabled: requests module not available")
            return
        
        try:
            embed = {
                "title": "🔄 Surge Container Updates Available",
                "description": f"Found updates for {len(updates)} container(s)",
                "color": 3447003,  # Blue color
                "timestamp": datetime.utcnow().isoformat(),
                "fields": [],
                "footer": {
                    "text": "Run './surge --update' to apply updates"
                }
            }
            
            for update in updates[:10]:  # Limit to 10 updates in notification
                service_name = update['service'].replace('-', ' ').title()
                field_value = f"Image: `{update['image']}`"
                
                if 'old_id' in update:
                    field_value += f"\nOld: `{update['old_id']}`\nNew: `{update['new_id']}`"
                elif 'local_digest' in update:
                    field_value += f"\nLocal: `{update['local_digest']}`\nRemote: `{update['remote_digest']}`"
                
                embed["fields"].append({
                    "name": f"📦 {service_name}",
                    "value": field_value,
                    "inline": True
                })
            
            if len(updates) > 10:
                embed["fields"].append({
                    "name": "➕ Additional Updates",
                    "value": f"And {len(updates) - 10} more services have updates available.",
                    "inline": False
                })
            
            payload = {
                "embeds": [embed],
                "content": f"🚨 **Surge Update Alert** - {len(updates)} container updates detected!"
            }
            
            response = requests.post(self.discord_webhook, json=payload, timeout=10)
            response.raise_for_status()
            
            logger.info(f"Discord notification sent for {len(updates)} updates")
            
        except Exception as e:
            logger.error(f"Failed to send Discord notification: {e}")
    
    async def run_once(self):
        """Run a single update check"""
        logger.info("Starting update check...")
        updates = await self.check_for_updates()
        
        if updates:
            logger.info(f"Found {len(updates)} updates available:")
            for update in updates:
                logger.info(f"  - {update['service']}: {update['image']}")
            
            await self.send_discord_notification(updates)
            return updates
        else:
            logger.info("No updates available")
            return []
    
    async def run_daemon(self):
        """Run as a daemon, checking for updates periodically"""
        logger.info(f"Starting update monitor daemon (check interval: {self.check_interval}s)")
        
        while True:
            try:
                await self.run_once()
                self.last_check = datetime.now()
                
                # Wait for next check interval
                await asyncio.sleep(self.check_interval)
                
            except KeyboardInterrupt:
                logger.info("Update monitor stopped by user")
                break
            except Exception as e:
                logger.error(f"Error in update monitor daemon: {e}")
                # Wait a bit before retrying
                await asyncio.sleep(60)

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Surge Container Update Monitor')
    parser.add_argument('--daemon', action='store_true', help='Run as daemon')
    parser.add_argument('--check-once', action='store_true', help='Run single check and exit')
    parser.add_argument('--interval', type=int, default=3600, help='Check interval in seconds (default: 3600)')
    
    args = parser.parse_args()
    
    # Set environment variable for interval
    if args.interval:
        os.environ['UPDATE_CHECK_INTERVAL'] = str(args.interval)
    
    monitor = UpdateMonitor()
    
    if args.daemon:
        asyncio.run(monitor.run_daemon())
    elif args.check_once:
        updates = asyncio.run(monitor.run_once())
        if updates:
            print(f"\n🔄 {len(updates)} updates available!")
            print("Run './surge --update' to apply updates")
            sys.exit(1)
        else:
            print("✅ All containers are up to date")
            sys.exit(0)
    else:
        print("Use --daemon to run as service or --check-once for single check")
        parser.print_help()

if __name__ == "__main__":
    main()
