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
        # Compose up only enabled services
        cmd = ['docker', 'compose', '-f', '../docker-compose.yml', 'up', '-d'] + list(enabled)
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            return jsonify({'status': 'deployed', 'output': result.stdout, 'services': list(enabled)})
        else:
            return jsonify({'status': 'error', 'output': result.stderr, 'services': list(enabled)}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
