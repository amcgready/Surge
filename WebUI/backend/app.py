# Autodetect endpoint for frontend to fetch default URLs and API keys
@app.route('/api/autodetect')
def autodetect():
    # Example autodetection logic (replace with real detection as needed)
    # This could read from environment, config files, or Docker network
    detected = {
        'prowlarrUrl': 'http://prowlarr:9696',
        'prowlarrApiKey': '',
        'radarrUrl': 'http://radarr:7878',
        'radarrApiKey': '',
        'sonarrUrl': 'http://sonarr:8989',
        'sonarrApiKey': ''
    }
    # Optionally, merge with any saved config
    detected.update(setup_config)
    return jsonify(detected)
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/ping')
def ping():
    return jsonify({'status': 'ok'})


# In-memory config store (replace with persistent storage as needed)
setup_config = {}

@app.route('/api/save_config', methods=['POST'])
def save_config():
    data = request.json
    setup_config.update(data)
    return jsonify({'status': 'saved', 'config': setup_config})

@app.route('/api/test_connection', methods=['POST'])
def test_connection():
    data = request.json
    # Example: test connection to a service (Prowlarr, Radarr, Sonarr)
    import requests
    url = data.get('url')
    api_key = data.get('api_key')
    try:
        headers = {'X-Api-Key': api_key} if api_key else {}
        resp = requests.get(url, headers=headers, timeout=5)
        return jsonify({'status': 'success', 'code': resp.status_code})
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)}), 400

@app.route('/api/deploy_services', methods=['POST'])
def deploy_services():
    import subprocess
    import os
    import configparser
    try:
        data = request.json or {}
        # Map frontend toggles to docker-compose service names
        toggle_map = {
            'radarr': 'radarr',
            'sonarr': 'sonarr',
            'bazarr': 'bazarr',
            'prowlarr': 'prowlarr',
            'nzbget': 'nzbget',
            'rdtclient': 'rdt-client',
            'zurg': 'zurg',
            'zilean': 'zilean',
            'cliDebrid': 'cli-debrid',
            'decypharr': 'decypharr',
            'posterizarr': 'posterizarr',
            'cinesync': 'cinesync',
            'placeholdarr': 'placeholdarr',
            'overseerr': 'overseerr',
            'tautulli': 'tautulli',
            'homepage': 'homepage',
            'gaps': 'gaps',
            'kometa': 'kometa',
            'plex': 'plex',
            'jellyfin': 'jellyfin',
            'emby': 'emby',
        }
        # Collect enabled services from toggles in config
        enabled = set()
        for group in ['mediaAutomation', 'downloadTools', 'contentEnhancement', 'monitoring']:
            toggles = data.get(group, {})
            for key, val in toggles.items():
                if val and key in toggle_map:
                    enabled.add(toggle_map[key])
        # Always include homepage if present in config
        if 'homepage' in toggle_map:
            enabled.add('homepage')
        if not enabled:
            return jsonify({'status': 'error', 'error': 'No services enabled'}), 400


        # Zurg: set default path if not provided (already not using shared config)
        zurg_settings = data.get('zurgSettings', {})
        zurg_dest = zurg_settings.get('destination')
        if not zurg_dest:
            zurg_dest = '/mnt/Zurg'
            if 'zurgSettings' not in data:
                data['zurgSettings'] = {}
            data['zurgSettings']['destination'] = zurg_dest

        # NZBGet: ensure destination_directory is present and not using shared config
        nzbget_defaults = {
            'destination_directory': '/mnt/mycloudpr4100/Surge/NZBGet/Downloads',
            'api_key': 'surgestack',
            'host': '0.0.0.0',
            'port': 6789,
            'username': 'admin',
            'password': 'surge',
        }
        if 'nzbgetSettings' not in data:
            data['nzbgetSettings'] = {}
        for k, v in nzbget_defaults.items():
            if k not in data['nzbgetSettings']:
                data['nzbgetSettings'][k] = v

        # CineSync: ensure all relevant settings exist
        cinesync_defaults = {
            'origin_directory': '/mnt/mycloudpr4100/Surge/CineSync/Origin',
            'destination_directory': '/mnt/mycloudpr4100/Surge/CineSync/Destination',
            'api_key': 'surgestack',
            'port': 8080,
            'host': '0.0.0.0',
            'log_level': 'info',
            'username': 'admin',
            'password': 'surge',
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'webhook_url': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'cinesyncSettings' not in data:
            data['cinesyncSettings'] = {}
        for k, v in cinesync_defaults.items():
            if k not in data['cinesyncSettings']:
                data['cinesyncSettings'][k] = v

        # Compose up only enabled services
        cmd = ['docker', 'compose', '-f', '../docker-compose.yml', 'up', '-d'] + list(enabled)
        result = subprocess.run(cmd, capture_output=True, text=True)

        # If bazarr is enabled, add Radarr/Sonarr to Bazarr config.ini using values from config
        bazarr_enabled = 'bazarr' in enabled
        radarr_enabled = 'radarr' in enabled
        sonarr_enabled = 'sonarr' in enabled
        bazarr_config_path = os.path.expandvars(os.path.join(os.path.dirname(__file__), '../../../config/Bazarr/config.ini'))
        if bazarr_enabled:
            config_ini = configparser.ConfigParser()
            if os.path.exists(bazarr_config_path):
                config_ini.read(bazarr_config_path)
            if radarr_enabled:
                config_ini['radarr'] = {
                    'enabled': 'True',
                    'url': data.get('radarrSettings', {}).get('urlBase', 'http://radarr:7878'),
                    'api_key': data.get('radarrSettings', {}).get('apiKey', 'surgestack'),
                }
            if sonarr_enabled:
                config_ini['sonarr'] = {
                    'enabled': 'True',
                    'url': data.get('sonarrSettings', {}).get('urlBase', 'http://sonarr:8989'),
                    'api_key': data.get('sonarrSettings', {}).get('apiKey', 'surgestack'),
                }
            os.makedirs(os.path.dirname(bazarr_config_path), exist_ok=True)
            with open(bazarr_config_path, 'w') as f:
                config_ini.write(f)

        # If prowlarr, radarr, and/or sonarr are enabled, use the Prowlarr API to add Radarr/Sonarr as connections
        import time
        import requests
        prowlarr_enabled = 'prowlarr' in enabled
        if prowlarr_enabled and (radarr_enabled or sonarr_enabled):
            time.sleep(5)
            prowlarr_url = data.get('prowlarrSettings', {}).get('urlBase') or 'http://prowlarr:9696'
            prowlarr_api_key = data.get('prowlarrSettings', {}).get('apiKey') or 'surgestack'
            headers = {'X-Api-Key': prowlarr_api_key, 'Content-Type': 'application/json'}
            if radarr_enabled:
                radarr_url = data.get('radarrSettings', {}).get('urlBase') or 'http://radarr:7878'
                radarr_api_key = data.get('radarrSettings', {}).get('apiKey') or 'surgestack'
                radarr_payload = {
                    'name': 'Radarr',
                    'implementation': 'Radarr',
                    'configContract': 'RadarrSettings',
                    'fields': [
                        {'name': 'apiKey', 'value': radarr_api_key},
                        {'name': 'baseUrl', 'value': radarr_url}
                    ],
                    'syncLevel': 'full',
                    'enableRss': True,
                    'enableAutomaticSearch': True,
                    'enableInteractiveSearch': True,
                    'isDefault': True
                }
                try:
                    requests.post(f'{prowlarr_url}/api/v1/applications', headers=headers, json=radarr_payload, timeout=10)
                except Exception as e:
                    pass
            if sonarr_enabled:
                sonarr_url = data.get('sonarrSettings', {}).get('urlBase') or 'http://sonarr:8989'
                sonarr_api_key = data.get('sonarrSettings', {}).get('apiKey') or 'surgestack'
                sonarr_payload = {
                    'name': 'Sonarr',
                    'implementation': 'Sonarr',
                    'configContract': 'SonarrSettings',
                    'fields': [
                        {'name': 'apiKey', 'value': sonarr_api_key},
                        {'name': 'baseUrl', 'value': sonarr_url}
                    ],
                    'syncLevel': 'full',
                    'enableRss': True,
                    'enableAutomaticSearch': True,
                    'enableInteractiveSearch': True,
                    'isDefault': True
                }
                try:
                    requests.post(f'{prowlarr_url}/api/v1/applications', headers=headers, json=sonarr_payload, timeout=10)
                except Exception as e:
                    pass

        if result.returncode == 0:
            return jsonify({'status': 'deployed', 'output': result.stdout, 'services': list(enabled)})
        else:
            return jsonify({'status': 'error', 'output': result.stderr, 'services': list(enabled)}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
