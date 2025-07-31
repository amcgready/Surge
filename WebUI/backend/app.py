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


        # Zurg: all documented Docker env vars and advanced options
        zurg_defaults = {
            'destination': '/mnt/Zurg',
            'api_key': 'surgestack',
            'log_level': 'info',
            'host': '0.0.0.0',
            'port': 9999,
            'username': 'admin',
            'password': 'surge',
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'webhook_url': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'zurgSettings' not in data:
            data['zurgSettings'] = {}
        for k, v in zurg_defaults.items():
            if k not in data['zurgSettings']:
                data['zurgSettings'][k] = v

        # NZBGet: all Docker env vars and advanced options
        nzbget_defaults = {
            'destination_directory': '/mnt/mycloudpr4100/Surge/NZBGet/Downloads',
            'api_key': 'surgestack',
            'host': '0.0.0.0',
            'port': 6789,
            'username': 'admin',
            'password': 'surge',
            'control_username': 'admin',
            'control_password': 'surge',
            'webui_port': 6789,
            'webui_username': 'admin',
            'webui_password': 'surge',
            'log_level': 'INFO',
            'extra_env': {},
            'extra_args': '',
        }
        if 'nzbgetSettings' not in data:
            data['nzbgetSettings'] = {}
        for k, v in nzbget_defaults.items():
            if k not in data['nzbgetSettings']:
                data['nzbgetSettings'][k] = v

        # CineSync: all Docker env vars and advanced options
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

        # --- BEGIN: All services, all documented Docker env vars and advanced config options ---
        # Radarr
        radarr_defaults = {
            'urlBase': 'http://radarr:7878',
            'apiKey': 'surgestack',
            'log_level': 'info',
            'host': '0.0.0.0',
            'port': 7878,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'PUID': 1000,
            'PGID': 1000,
            'TZ': 'UTC',
            'UMASK': '002',
            'extra_env': {},
            'extra_args': '',
        }
        if 'radarrSettings' not in data:
            data['radarrSettings'] = {}
        for k, v in radarr_defaults.items():
            if k not in data['radarrSettings']:
                data['radarrSettings'][k] = v

        # Sonarr
        sonarr_defaults = {
            'urlBase': 'http://sonarr:8989',
            'apiKey': 'surgestack',
            'log_level': 'info',
            'host': '0.0.0.0',
            'port': 8989,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'PUID': 1000,
            'PGID': 1000,
            'TZ': 'UTC',
            'UMASK': '002',
            'config_path': '/config',
            'tv_path': '/tv',
            'downloads_path': '/downloads',
            'read_only': False,  # Advanced
            'user_override': '', # Advanced, e.g. '1000:1000'
            'docker_secrets': {}, # Advanced, e.g. {'FILE__MYVAR': '/run/secrets/mysecretvariable'}
            'extra_env': {},
            'extra_args': '',
        }
        if 'sonarrSettings' not in data:
            data['sonarrSettings'] = {}
        for k, v in sonarr_defaults.items():
            if k not in data['sonarrSettings']:
                data['sonarrSettings'][k] = v

        # Prowlarr
        prowlarr_defaults = {
            'urlBase': 'http://prowlarr:9696',
            'apiKey': 'surgestack',
            'log_level': 'info',
            'host': '0.0.0.0',
            'port': 9696,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'PUID': 1000,
            'PGID': 1000,
            'TZ': 'UTC',
            'UMASK': '002',
            'extra_env': {},
            'extra_args': '',
        }
        if 'prowlarrSettings' not in data:
            data['prowlarrSettings'] = {}
        for k, v in prowlarr_defaults.items():
            if k not in data['prowlarrSettings']:
                data['prowlarrSettings'][k] = v

        # Bazarr
        bazarr_defaults = {
            'urlBase': 'http://bazarr:6767',
            'apiKey': 'surgestack',
            'log_level': 'info',
            'host': '0.0.0.0',
            'port': 6767,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'PUID': 1000,
            'PGID': 1000,
            'TZ': 'UTC',
            'UMASK': '002',
            'extra_env': {},
            'extra_args': '',
        }
        if 'bazarrSettings' not in data:
            data['bazarrSettings'] = {}
        for k, v in bazarr_defaults.items():
            if k not in data['bazarrSettings']:
                data['bazarrSettings'][k] = v

        # Placeholdarr
        placeholdarr_defaults = {
            'PLEX_URL': '',
            'PLEX_TOKEN': '',
            'RADARR_URL': '',
            'RADARR_API_KEY': '',
            'SONARR_URL': '',
            'SONARR_API_KEY': '',
            'MOVIE_LIBRARY_FOLDER': '',
            'TV_LIBRARY_FOLDER': '',
            'DUMMY_FILE_PATH': '/data/dummy.mp4',
            'PLACEHOLDER_STRATEGY': 'hardlink',
            'TV_PLAY_MODE': 'episode',
            'TITLE_UPDATES': 'OFF',
            'INCLUDE_SPECIALS': False,
            'EPISODES_LOOKAHEAD': 0,
            'MAX_MONITOR_TIME': 0,
            'CHECK_INTERVAL': 0,
            'AVAILABLE_CLEANUP_DELAY': 0,
            'CALENDAR_LOOKAHEAD_DAYS': 0,
            'CALENDAR_SYNC_INTERVAL_HOURS': 0,
            'ENABLE_COMING_SOON_PLACEHOLDERS': False,
            'PREFERRED_MOVIE_DATE_TYPE': 'inCinemas',
            'ENABLE_COMING_SOON_COUNTDOWN': False,
            'CALENDAR_PLACEHOLDER_MODE': 'episode',
            'extra_env': {},
            'extra_args': '',
        }
        if 'placeholdarrSettings' not in data:
            data['placeholdarrSettings'] = {}
        for k, v in placeholdarr_defaults.items():
            if k not in data['placeholdarrSettings']:
                data['placeholdarrSettings'][k] = v

        # RDT-Client
        rdtclient_defaults = {
            'REALDEBRID_API_KEY': '',
            'DOWNLOAD_PATH': '/data/downloads',
            'MAPPED_PATH': '/data/downloads',
            'BASE_PATH': '/',
            'LOG_LEVEL': 'Info',
            'extra_env': {},
            'extra_args': '',
        }
        if 'rdtclientSettings' not in data:
            data['rdtclientSettings'] = {}
        for k, v in rdtclient_defaults.items():
            if k not in data['rdtclientSettings']:
                data['rdtclientSettings'][k] = v

        # Zilean
        zilean_defaults = {
            'API_KEY': '',
            'ZURG_URL': '',
            'LOG_LEVEL': 'info',
            'PORT': 8080,
            'extra_env': {},
            'extra_args': '',
        }
        if 'zileanSettings' not in data:
            data['zileanSettings'] = {}
        for k, v in zilean_defaults.items():
            if k not in data['zileanSettings']:
                data['zileanSettings'][k] = v

        # Gaps
        gaps_defaults = {
            'BASE_URL': '',
            'PLEX_HOST': '',
            'PLEX_PORT': 32400,
            'PLEX_TOKEN': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'gapsSettings' not in data:
            data['gapsSettings'] = {}
        for k, v in gaps_defaults.items():
            if k not in data['gapsSettings']:
                data['gapsSettings'][k] = v

        # cli-debrid
        clidebrid_defaults = {
            'PLEX_URL': '',
            'DEBRID_PROVIDER': '',
            'TRAKT_API_KEY': '',
            'TMDB_API_KEY': '',
            'NOTIFICATIONS_DISCORD': '',
            'NOTIFICATIONS_EMAIL': '',
            'NOTIFICATIONS_TELEGRAM': '',
            'NOTIFICATIONS_NTFY': '',
            'LOG_LEVEL': 'info',
            'extra_env': {},
            'extra_args': '',
        }
        if 'cliDebridSettings' not in data:
            data['cliDebridSettings'] = {}
        for k, v in clidebrid_defaults.items():
            if k not in data['cliDebridSettings']:
                data['cliDebridSettings'][k] = v

        # Decypharr
        decypharr_defaults = {
            'urlBase': 'http://decypharr:8282',
            'apiKey': 'surgestack',
            'debrids': [],
            'qbittorrent': {},
            'use_auth': False,
            'log_level': 'info',
            'host': '0.0.0.0',
            'port': 8282,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'decypharrSettings' not in data:
            data['decypharrSettings'] = {}
        for k, v in decypharr_defaults.items():
            if k not in data['decypharrSettings']:
                data['decypharrSettings'][k] = v

        # Kometa
        kometa_defaults = {
            'urlBase': 'http://kometa:8081',
            'apiKey': 'surgestack',
            'CONFIG_PATH': '/config/config.yml',
            'LOG_LEVEL': 'info',
            'TZ': 'UTC',
            'PUID': 1000,
            'PGID': 1000,
            'UMASK': '002',
            'host': '0.0.0.0',
            'port': 8081,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'kometaSettings' not in data:
            data['kometaSettings'] = {}
        for k, v in kometa_defaults.items():
            if k not in data['kometaSettings']:
                data['kometaSettings'][k] = v

        # ImageMaid
        imagemaid_defaults = {
            'urlBase': 'http://imagemaid:8090',
            'apiKey': 'surgestack',
            'PLEX_PATH': '',
            'MODE': 'report',
            'SCHEDULE': '',
            'PLEX_URL': '',
            'PLEX_TOKEN': '',
            'DISCORD': '',
            'TIMEOUT': 600,
            'SLEEP': 60,
            'IGNORE_RUNNING': False,
            'LOCAL_DB': False,
            'USE_EXISTING': False,
            'PHOTO_TRANSCODER': False,
            'EMPTY_TRASH': False,
            'CLEAN_BUNDLES': False,
            'OPTIMIZE_DB': False,
            'TRACE': False,
            'LOG_REQUESTS': False,
            'host': '0.0.0.0',
            'port': 8090,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'imageMaidSettings' not in data:
            data['imageMaidSettings'] = {}
        for k, v in imagemaid_defaults.items():
            if k not in data['imageMaidSettings']:
                data['imageMaidSettings'][k] = v

        # Posterizarr
        posterizarr_defaults = {
            'urlBase': 'http://posterizarr:8082',
            'apiKey': 'surgestack',
            'config_path': '/config/config.json',
            'RUN_TIME': 'disabled',
            'TZ': 'UTC',
            'PUID': 1000,
            'PGID': 1000,
            'UMASK': '002',
            'host': '0.0.0.0',
            'port': 8082,
            'enable_ssl': False,
            'ssl_cert': '',
            'ssl_key': '',
            'PosterMinHeight': 3000,
            'BgTcMinWidth': 3840,
            'BgTcMinHeight': 2160,
            'tmdb_vote_sorting': 'vote_average',
            'PreferredLanguageOrder': 'xx,en,de',
            'ForceRunningDeletion': False,
            'AutoUpdatePosterizarr': False,
            'show_skipped': False,
            'magickinstalllocation': './magick',
            'fontAllCaps': False,
            'AddBorder': False,
            'AddText': False,
            'AddTextStroke': False,
            'strokecolor': '',
            'strokewidth': 0,
            'AddOverlay': False,
            'fontcolor': '',
            'bordercolor': '',
            'minPointSize': 0,
            'maxPointSize': 0,
            'borderwidth': 0,
            'MaxWidth': 0,
            'MaxHeight': 0,
            'extra_env': {},
            'extra_args': '',
        }
        if 'posterizarrSettings' not in data:
            data['posterizarrSettings'] = {}
        for k, v in posterizarr_defaults.items():
            if k not in data['posterizarrSettings']:
                data['posterizarrSettings'][k] = v

        # Overseerr
        overseerr_defaults = {
            'PORT': 5055,
            'TZ': 'UTC',
            'LOG_LEVEL': 'info',
            'extra_env': {},
            'extra_args': '',
        }
        if 'overseerrSettings' not in data:
            data['overseerrSettings'] = {}
        for k, v in overseerr_defaults.items():
            if k not in data['overseerrSettings']:
                data['overseerrSettings'][k] = v

        # Tautulli
        tautulli_defaults = {
            'TZ': 'UTC',
            'PUID': 1000,
            'PGID': 1000,
            'extra_env': {},
            'extra_args': '',
        }
        if 'tautulliSettings' not in data:
            data['tautulliSettings'] = {}
        for k, v in tautulli_defaults.items():
            if k not in data['tautulliSettings']:
                data['tautulliSettings'][k] = v

        # Homepage
        homepage_defaults = {
            'HOMEPAGE_ALLOWED_HOSTS': 'gethomepage.dev',
            'PUID': 1000,
            'PGID': 1000,
            'TZ': 'UTC',
            'extra_env': {},
            'extra_args': '',
        }
        if 'homepageSettings' not in data:
            data['homepageSettings'] = {}
        for k, v in homepage_defaults.items():
            if k not in data['homepageSettings']:
                data['homepageSettings'][k] = v

        # Plex
        plex_defaults = {
            'HOSTNAME': 'PlexServer',
            'TZ': 'UTC',
            'PLEX_CLAIM': '',
            'ADVERTISE_IP': '',
            'PLEX_UID': 1000,
            'PLEX_GID': 1000,
            'CHANGE_CONFIG_DIR_OWNERSHIP': True,
            'ALLOWED_NETWORKS': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'plexSettings' not in data:
            data['plexSettings'] = {}
        for k, v in plex_defaults.items():
            if k not in data['plexSettings']:
                data['plexSettings'][k] = v

        # Jellyfin
        jellyfin_defaults = {
            'TZ': 'UTC',
            'JELLYFIN_PublishedServerUrl': '',
            'JELLYFIN_LOG_DIR': '',
            'JELLYFIN_DATA_DIR': '',
            'JELLYFIN_CONFIG_DIR': '',
            'JELLYFIN_CACHE_DIR': '',
            'JELLYFIN_FFMPEG_PATH': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'jellyfinSettings' not in data:
            data['jellyfinSettings'] = {}
        for k, v in jellyfin_defaults.items():
            if k not in data['jellyfinSettings']:
                data['jellyfinSettings'][k] = v

        # Emby
        emby_defaults = {
            'TZ': 'UTC',
            'EMBY_DATA_DIR': '',
            'EMBY_CONFIG_DIR': '',
            'EMBY_CACHE_DIR': '',
            'extra_env': {},
            'extra_args': '',
        }
        if 'embySettings' not in data:
            data['embySettings'] = {}
        for k, v in emby_defaults.items():
            if k not in data['embySettings']:
                data['embySettings'][k] = v
        # --- END: All services ---

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
