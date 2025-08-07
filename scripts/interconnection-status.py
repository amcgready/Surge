#!/usr/bin/env python3
"""
Surge Service Interconnection Status Checker
Verifies that all enabled services are properly interconnected and configured
"""

import os
import sys
import json
import requests
import xml.etree.ElementTree as ET
import configparser
from datetime import datetime

class SurgeInterconnectionChecker:
    def __init__(self, storage_path=None):
        self.storage_path = storage_path or os.environ.get('STORAGE_PATH', '/opt/surge')
        self.enabled_services = self.detect_enabled_services()
        
    def log(self, message, level="INFO"):
        """Enhanced logging with timestamps."""
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {
            "INFO": "ℹ️", "SUCCESS": "✅", "WARNING": "⚠️", 
            "ERROR": "❌", "DEBUG": "🔍", "CHECKED": "🔍"
        }
        icon = icons.get(level, "ℹ️")
        print(f"[{timestamp}] {icon} {message}")
        sys.stdout.flush()
    
    def detect_enabled_services(self):
        """Detect which services are enabled and running."""
        services = []
        
        # Check environment variables
        service_checks = {
            'plex': os.environ.get('MEDIA_SERVER', '').lower() == 'plex',
            'emby': os.environ.get('MEDIA_SERVER', '').lower() == 'emby', 
            'jellyfin': os.environ.get('MEDIA_SERVER', '').lower() == 'jellyfin',
            'radarr': os.environ.get('ENABLE_RADARR', 'true').lower() == 'true',
            'sonarr': os.environ.get('ENABLE_SONARR', 'true').lower() == 'true',
            'prowlarr': os.environ.get('ENABLE_PROWLARR', 'true').lower() == 'true',
            'bazarr': os.environ.get('ENABLE_BAZARR', 'false').lower() == 'true',
            'overseerr': os.environ.get('ENABLE_OVERSEERR', 'false').lower() == 'true',
            'tautulli': os.environ.get('ENABLE_TAUTULLI', 'false').lower() == 'true',
            'nzbget': os.environ.get('ENABLE_NZBGET', 'false').lower() == 'true',
            'rdt-client': os.environ.get('ENABLE_RDT_CLIENT', 'false').lower() == 'true',
            'zurg': os.environ.get('ENABLE_ZURG', 'false').lower() == 'true',
            'kometa': os.environ.get('ENABLE_KOMETA', 'false').lower() == 'true',
            'gaps': os.environ.get('ENABLE_GAPS', 'false').lower() == 'true',
            'posterizarr': os.environ.get('ENABLE_POSTERIZARR', 'false').lower() == 'true',
            'cinesync': os.environ.get('ENABLE_CINESYNC', 'false').lower() == 'true'
        }
        
        for service, enabled in service_checks.items():
            if enabled:
                services.append(service)
        
        return services
    
    def check_service_running(self, service, port):
        """Check if a service is running and accessible."""
        try:
            response = requests.get(f"http://localhost:{port}", timeout=5)
            return response.status_code < 500
        except:
            return False
    
    def check_prowlarr_applications(self):
        """Check if Prowlarr has Radarr and Sonarr configured."""
        if 'prowlarr' not in self.enabled_services:
            return {"configured": False, "reason": "Prowlarr not enabled"}
        
        try:
            # Get Prowlarr API key
            config_path = f"{self.storage_path}/config/prowlarr/config.xml"
            if not os.path.exists(config_path):
                return {"configured": False, "reason": "Prowlarr config not found"}
            
            tree = ET.parse(config_path)
            root = tree.getroot()
            api_key_element = root.find('ApiKey')
            
            if not api_key_element or not api_key_element.text:
                return {"configured": False, "reason": "Prowlarr API key not found"}
            
            api_key = api_key_element.text.strip()
            
            # Check applications
            response = requests.get(
                "http://localhost:9696/api/v1/applications",
                headers={"X-Api-Key": api_key},
                timeout=10
            )
            
            if response.status_code == 200:
                applications = response.json()
                app_names = [app['name'] for app in applications]
                
                configured_apps = []
                if 'radarr' in self.enabled_services and any('radarr' in name.lower() for name in app_names):
                    configured_apps.append('Radarr')
                if 'sonarr' in self.enabled_services and any('sonarr' in name.lower() for name in app_names):
                    configured_apps.append('Sonarr')
                
                return {"configured": True, "applications": configured_apps}
            else:
                return {"configured": False, "reason": f"API error: {response.status_code}"}
                
        except Exception as e:
            return {"configured": False, "reason": f"Error: {e}"}
    
    def check_bazarr_providers(self):
        """Check if Bazarr has Radarr/Sonarr providers configured."""
        if 'bazarr' not in self.enabled_services:
            return {"configured": False, "reason": "Bazarr not enabled"}
        
        try:
            # Get Bazarr API key
            config_path = f"{self.storage_path}/config/bazarr/config/config.ini"
            if not os.path.exists(config_path):
                return {"configured": False, "reason": "Bazarr config not found"}
            
            config = configparser.ConfigParser()
            config.read(config_path)
            
            if not config.has_section('auth') or not config.has_option('auth', 'apikey'):
                return {"configured": False, "reason": "Bazarr API key not found"}
            
            api_key = config.get('auth', 'apikey')
            
            # Check providers
            response = requests.get(
                "http://localhost:6767/api/providers",
                headers={"X-API-KEY": api_key},
                timeout=10
            )
            
            if response.status_code == 200:
                providers = response.json()
                configured_providers = []
                
                for provider in providers:
                    if provider.get('name', '').lower() in ['radarr', 'sonarr']:
                        configured_providers.append(provider['name'])
                
                return {"configured": True, "providers": configured_providers}
            else:
                return {"configured": False, "reason": f"API error: {response.status_code}"}
                
        except Exception as e:
            return {"configured": False, "reason": f"Error: {e}"}
    
    def check_download_clients(self, service):
        """Check download clients in Radarr/Sonarr."""
        if service not in self.enabled_services:
            return {"configured": False, "reason": f"{service.title()} not enabled"}
        
        try:
            # Get API key
            config_path = f"{self.storage_path}/config/{service}/config.xml"
            if not os.path.exists(config_path):
                return {"configured": False, "reason": f"{service.title()} config not found"}
            
            tree = ET.parse(config_path)
            root = tree.getroot()
            api_key_element = root.find('ApiKey')
            
            if not api_key_element or not api_key_element.text:
                return {"configured": False, "reason": f"{service.title()} API key not found"}
            
            api_key = api_key_element.text.strip()
            port = {'radarr': 7878, 'sonarr': 8989}[service]
            
            # Check download clients
            response = requests.get(
                f"http://localhost:{port}/api/v3/downloadclient",
                headers={"X-Api-Key": api_key},
                timeout=10
            )
            
            if response.status_code == 200:
                clients = response.json()
                configured_clients = []
                
                for client in clients:
                    if client.get('enable', False):
                        configured_clients.append(client.get('name', 'Unknown'))
                
                return {"configured": True, "clients": configured_clients}
            else:
                return {"configured": False, "reason": f"API error: {response.status_code}"}
                
        except Exception as e:
            return {"configured": False, "reason": f"Error: {e}"}
    
    def check_media_server_connections(self):
        """Check media server related connections."""
        connections = {}
        
        # Check Tautulli → Plex connection
        if 'tautulli' in self.enabled_services and 'plex' in self.enabled_services:
            config_path = f"{self.storage_path}/config/tautulli/config.ini"
            if os.path.exists(config_path):
                config = configparser.ConfigParser()
                config.read(config_path)
                
                has_plex_token = (config.has_section('General') and 
                                config.has_option('General', 'pms_token') and 
                                config.get('General', 'pms_token'))
                
                connections['tautulli_plex'] = {
                    "configured": bool(has_plex_token),
                    "reason": "Plex token configured" if has_plex_token else "No Plex token found"
                }
        
        # Check Kometa → Plex connection
        if 'kometa' in self.enabled_services and 'plex' in self.enabled_services:
            config_path = f"{self.storage_path}/config/kometa/config.yml"
            if os.path.exists(config_path):
                try:
                    with open(config_path, 'r') as f:
                        content = f.read()
                        has_token = 'token:' in content and '${PLEX_TOKEN}' in content
                        connections['kometa_plex'] = {
                            "configured": has_token,
                            "reason": "Plex token configured" if has_token else "No Plex token found"
                        }
                except:
                    connections['kometa_plex'] = {"configured": False, "reason": "Config read error"}
        
        return connections
    
    def generate_status_report(self):
        """Generate comprehensive interconnection status report."""
        self.log("🔍 Surge Service Interconnection Status Report", "INFO")
        self.log("=" * 60, "INFO")
        
        total_checks = 0
        passed_checks = 0
        
        # Service availability
        self.log("\n📊 Service Availability:", "INFO")
        service_ports = {
            'plex': 32400, 'emby': 8096, 'jellyfin': 8096,
            'radarr': 7878, 'sonarr': 8989, 'prowlarr': 9696,
            'bazarr': 6767, 'overseerr': 5055, 'tautulli': 8182,
            'nzbget': 6789, 'rdt-client': 6500, 'gaps': 8484
        }
        
        for service in self.enabled_services:
            if service in service_ports:
                running = self.check_service_running(service, service_ports[service])
                status = "✅ Running" if running else "❌ Not accessible"
                self.log(f"  {service.title()}: {status}", "CHECKED")
                total_checks += 1
                if running:
                    passed_checks += 1
        
        # Prowlarr ↔ Applications
        self.log("\n🔗 Prowlarr Application Connections:", "INFO")
        prowlarr_status = self.check_prowlarr_applications()
        total_checks += 1
        if prowlarr_status["configured"]:
            apps = ", ".join(prowlarr_status.get("applications", []))
            self.log(f"  ✅ Configured applications: {apps}", "SUCCESS")
            passed_checks += 1
        else:
            self.log(f"  ❌ Not configured: {prowlarr_status['reason']}", "ERROR")
        
        # Bazarr ↔ Providers
        self.log("\n📺 Bazarr Provider Connections:", "INFO")
        bazarr_status = self.check_bazarr_providers()
        total_checks += 1
        if bazarr_status["configured"]:
            providers = ", ".join(bazarr_status.get("providers", []))
            self.log(f"  ✅ Configured providers: {providers}", "SUCCESS")
            passed_checks += 1
        else:
            self.log(f"  ❌ Not configured: {bazarr_status['reason']}", "ERROR")
        
        # Download Clients
        self.log("\n⬇️ Download Client Connections:", "INFO")
        for service in ['radarr', 'sonarr']:
            if service in self.enabled_services:
                client_status = self.check_download_clients(service)
                total_checks += 1
                if client_status["configured"]:
                    clients = ", ".join(client_status.get("clients", []))
                    self.log(f"  ✅ {service.title()} clients: {clients}", "SUCCESS")
                    passed_checks += 1
                else:
                    self.log(f"  ❌ {service.title()}: {client_status['reason']}", "ERROR")
        
        # Media Server Connections
        self.log("\n📺 Media Server Connections:", "INFO")
        media_connections = self.check_media_server_connections()
        for conn_name, conn_status in media_connections.items():
            total_checks += 1
            service_name = conn_name.replace('_', ' → ').title()
            if conn_status["configured"]:
                self.log(f"  ✅ {service_name}: {conn_status['reason']}", "SUCCESS")
                passed_checks += 1
            else:
                self.log(f"  ❌ {service_name}: {conn_status['reason']}", "ERROR")
        
        # Summary
        self.log(f"\n📋 Summary:", "INFO")
        self.log(f"  Enabled Services: {len(self.enabled_services)}", "INFO")
        self.log(f"  Services: {', '.join(self.enabled_services)}", "INFO")
        self.log(f"  Interconnection Checks: {passed_checks}/{total_checks}", "INFO")
        
        if passed_checks == total_checks:
            self.log("  🎯 Status: All interconnections configured!", "SUCCESS")
        else:
            self.log(f"  ⚠️ Status: {total_checks - passed_checks} issues need attention", "WARNING")
        
        return passed_checks == total_checks

def main():
    """Main execution function."""
    storage_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    checker = SurgeInterconnectionChecker(storage_path)
    
    try:
        all_configured = checker.generate_status_report()
        return 0 if all_configured else 1
    except Exception as e:
        checker.log(f"Status check failed: {e}", "ERROR")
        return 1

if __name__ == "__main__":
    sys.exit(main())
