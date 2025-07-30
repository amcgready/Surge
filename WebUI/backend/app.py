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
    # Example: trigger docker compose up for main services
    import subprocess
    try:
        result = subprocess.run(['docker', 'compose', '-f', '../docker-compose.yml', 'up', '-d'], capture_output=True, text=True)
        if result.returncode == 0:
            return jsonify({'status': 'deployed', 'output': result.stdout})
        else:
            return jsonify({'status': 'error', 'output': result.stderr}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
