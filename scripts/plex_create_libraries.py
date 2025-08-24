import sys
import os
import json
from plexapi.server import PlexServer

if len(sys.argv) != 2:
    print("Usage: plex_create_libraries.py <LIBRARIES_JSON>")
    sys.exit(1)

libraries_json_path = sys.argv[1]
plex_token = os.environ.get("PLEX_TOKEN")
if not plex_token:
    print("Error: PLEX_TOKEN environment variable not set.")
    sys.exit(1)

baseurl = 'http://localhost:32400'
plex = PlexServer(baseurl, plex_token)

try:
    with open(libraries_json_path, 'r') as f:
        libraries = json.load(f)
except Exception as e:
    print(f"Failed to read libraries.json: {e}")
    sys.exit(1)

for lib in libraries:
    name = lib.get('name')
    lib_type = lib.get('type')
    location = lib.get('location')
    if not name or not lib_type or not location:
        print(f"Skipping invalid library definition: {lib}")
        continue
    print(f"Creating Plex library: {name} ({lib_type}) at {location}")
    try:
        plex.createLibrary(name, lib_type, location)
        print(f"Library '{name}' created successfully.")
    except Exception as e:
        print(f"Failed to create library '{name}': {e}")
