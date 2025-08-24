import sys
import json
import os
from urllib.parse import urlencode
import requests
from dotenv import load_dotenv

# Load environment variables from .env file in project directory
project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
env_path = os.path.join(project_dir, '.env')
load_dotenv(env_path)

plex_token = os.environ.get('PLEX_TOKEN')
if not plex_token:
    print("Error: PLEX_TOKEN environment variable not set.")
    sys.exit(1)

# Allow overriding the base URL; default to local Plex
baseurl = os.environ.get('PLEX_URL', 'http://localhost:32400').rstrip('/')

# Always use STORAGE_PATH for libraries_json_path
storage_path = os.environ.get('STORAGE_PATH')
if not storage_path:
    print("Error: STORAGE_PATH environment variable not set.")
    sys.exit(1)

libraries_json_path = os.path.join(
    storage_path,
    'Plex',
    'config',
    'Library',
    'Application Support',
    'Plex Media Server',
    'Libraries.json'
)

# Current agent/scanner map and language defaults
# Types on the wire: movie/show/artist/photo
PLEX_TYPE_MAP = {
    'movie': ('movie',  'tv.plex.agents.movie',   'Plex Movie',     'en-US'),
    'show':  ('show',   'tv.plex.agents.series',  'Plex TV Series', 'en-US'),
    'music': ('artist', 'tv.plex.agents.music',   'Plex Music',     'en'),
    'photo': ('photo',  'com.plexapp.agents.none','Plex Photo',     'en'),
}

# Load libraries definition JSON
try:
    with open(libraries_json_path, 'r', encoding='utf-8') as f:
        libraries = json.load(f)
except Exception as e:
    print(f"Failed to read libraries.json: {e}")
    sys.exit(1)

# Normalize libraries structure to a list
if isinstance(libraries, dict):
    libraries = libraries.get('libraries') or libraries.get('items') or []
elif not isinstance(libraries, list):
    print("Invalid libraries.json structure.")
    sys.exit(1)

# Host->container path translation base
storage_media_root = os.path.join(storage_path, 'downloads', 'CineSync')

session = requests.Session()

for lib in libraries:
    name = lib.get('name')
    lib_type = lib.get('type')
    location = lib.get('location') or lib.get('locations')

    if not name or not lib_type or not location:
        print(f"Skipping invalid library definition: {lib}")
        continue

    # Support single string or list of locations
    if isinstance(location, str):
        locations = [location]
    elif isinstance(location, list):
        locations = location
    else:
        print(f"Skipping library with bad location field: {lib}")
        continue

    # Map to container paths for Plex (replace host media root with /media)
    plex_locations = []
    for loc in locations:
        if isinstance(loc, str) and loc.startswith(storage_media_root):
            plex_locations.append(loc.replace(storage_media_root, '/media', 1))
        else:
            plex_locations.append(loc)

    plex_type, agent, scanner, language = PLEX_TYPE_MAP.get(
        lib_type, ('movie', 'tv.plex.agents.movie', 'Plex Movie', 'en-US')
    )

    # Build params; repeat 'location' key for each folder
    params = [
        ('name', name),
        ('type', plex_type),
        ('agent', agent),
        ('scanner', scanner),
        ('language', language),
    ]
    for p in plex_locations:
        params.append(('location', p))
    params.append(('X-Plex-Token', plex_token))

    print(f"Creating Plex library: {name} ({plex_type}) at {', '.join(plex_locations)}")
    full_url = f"{baseurl}/library/sections?{urlencode(params)}"
    print(f"Request URL: {full_url}")

    try:
        resp = session.post(f"{baseurl}/library/sections", params=params, timeout=30)
        print(f"POST status: {resp.status_code}")
        if resp.status_code != 201:
            # Echo server response for diagnostics
            body = resp.text.strip()
            if not body:
                body = "<empty response body>"
            print(f"POST failed: {body}")
        else:
            print(f"Library '{name}' created successfully.")
    except Exception as e:
        print(f"POST error: {e}")
