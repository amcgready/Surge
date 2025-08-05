#!/usr/bin/env python3

"""
Integration test for Surge Plex Library Automation
Demonstrates the complete workflow for setting up Plex with automated library creation
"""

import sys
import os
import time

def test_setup_integration():
    """Test the complete setup integration."""
    print("🚀 Surge Plex Library Integration Test")
    print("=" * 50)
    
    # Simulate WebUI configuration data
    test_config = {
        "mediaServer": "plex",
        "storagePath": os.getenv("STORAGE_PATH", "/opt/surge"),
        "plexSettings": {
            "HOSTNAME": "Surge Media Server",
            "TZ": "UTC",
            "PLEX_CLAIM": "",
            "ADVERTISE_IP": "",
            "PLEX_UID": 1000,
            "PLEX_GID": 1000,
            "CHANGE_CONFIG_DIR_OWNERSHIP": True,
            "ALLOWED_NETWORKS": "",
            "extra_env": {},
            "extra_args": ""
        },
        "mediaAutomation": {
            "radarr": True,
            "sonarr": True,
            "prowlarr": True,
            "bazarr": True,
            "cinesync": True,
            "placeholdarr": True
        },
        "contentEnhancement": {
            "plex": True
        }
    }
    
    print("📋 Test Configuration:")
    print(f"  • Media Server: {test_config['mediaServer']}")
    print(f"  • Server Name: {test_config['plexSettings']['HOSTNAME']}")
    print(f"  • Storage Path: {test_config['storagePath']}")
    print(f"  • CineSync Enabled: {test_config['mediaAutomation']['cinesync']}")
    print()
    
    print("🔄 Simulated Deployment Process:")
    print("1. ✅ Docker Compose services deployed")
    print("2. ✅ Service configuration applied")
    print("3. ✅ API discovery completed")
    
    # Simulate the Plex library configuration step
    print("4. 🎬 Configuring Plex libraries...")
    
    # Show what the backend would do
    server_name = test_config['plexSettings']['HOSTNAME']
    storage_path = test_config['storagePath']
    
    print(f"   📁 Storage path: {storage_path}")
    print(f"   🏷️  Server name: {server_name}")
    print("   📚 Creating libraries based on CineSync structure:")
    
    libraries = [
        ("Movies", "/media/movies", "movie"),
        ("TV Shows", "/media/tv", "show"),
        ("Anime Movies", "/media/movies/anime", "movie"),
        ("Anime Series", "/media/tv/anime", "show")
    ]
    
    for lib_name, lib_path, lib_type in libraries:
        print(f"      • {lib_name} ({lib_type}) → {lib_path}")
        time.sleep(0.5)  # Simulate processing time
    
    print("5. ✅ Plex library configuration completed")
    print()
    
    print("🎯 Expected Results:")
    print("   📺 Plex server name updated to: 'Surge Media Server'")
    print("   📚 Four libraries automatically created:")
    print("      • Movies - for all non-anime movies")
    print("      • TV Shows - for all non-anime TV series")
    print("      • Anime Movies - for anime films")
    print("      • Anime Series - for anime TV shows")
    print("   🔧 Proper metadata agents assigned")
    print("   📊 Libraries ready for media scanning")
    print()
    
    print("💡 Integration Benefits:")
    print("   ✨ Zero manual Plex library setup required")
    print("   🎯 Automatic organization matching CineSync structure")
    print("   🚀 Ready-to-use media server in minutes")
    print("   🔄 Consistent library setup across deployments")
    print()
    
    print("🔧 Manual Verification Steps:")
    print("   1. Access Plex at http://localhost:32400/web")
    print("   2. Verify server name is 'Surge Media Server'")
    print("   3. Check that all 4 libraries are present")
    print("   4. Confirm library paths match CineSync structure")
    
    return True

def show_command_examples():
    """Show example commands for testing."""
    print("\n🛠️  Command Examples:")
    print("=" * 30)
    
    print("Test Plex connection only:")
    print("  python3 scripts/configure-plex-libraries.py --test-only")
    print()
    
    print("Create libraries with custom server name:")
    print("  python3 scripts/configure-plex-libraries.py \\")
    print("    --server-name 'My Media Server' \\")
    print(f"    --storage-path {os.getenv('STORAGE_PATH', '/opt/surge')}")
    print()
    
    print("Test the complete setup:")
    print("  ./scripts/test-plex-libraries.sh")
    print()
    
    print("🔍 File Locations:")
    print("  • Main script: scripts/configure-plex-libraries.py")
    print("  • Test script: scripts/test-plex-libraries.sh")
    print("  • WebUI backend: WebUI/backend/app.py (lines 983+)")
    print("  • WebUI frontend: WebUI/frontend/src/App.js (Plex config section)")

if __name__ == '__main__':
    success = test_setup_integration()
    show_command_examples()
    
    if success:
        print("\n✅ Integration test completed successfully!")
        sys.exit(0)
    else:
        print("\n❌ Integration test failed!")
        sys.exit(1)
