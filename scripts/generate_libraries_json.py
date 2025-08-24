import os
import json
import sys
from dotenv import load_dotenv

# Load environment variables from .env file in project directory
project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
env_path = os.path.join(project_dir, '.env')
load_dotenv(env_path)

# Always use STORAGE_PATH for cinesync_media_root and output_json_path
storage_path = os.environ.get('STORAGE_PATH')
if not storage_path:
    print("Error: STORAGE_PATH environment variable not set.")
    sys.exit(1)
cinesync_media_root = os.path.join(storage_path, 'downloads', 'CineSync')
output_json_path = os.path.join(storage_path, 'Plex', 'config', 'Library', 'Application Support', 'Plex Media Server', 'Libraries.json')

# Map folder names to Plex library types
LIBRARY_TYPE_MAP = {
    "Movies": "movie",
    "TV Series": "show",
    "Anime Series": "show",
    "Anime Movies": "movie",
    "4K Movies": "movie",
    "4K TV Series": "show",
    # Add more mappings as needed
}

def guess_library_type(folder_name):
    for key, value in LIBRARY_TYPE_MAP.items():
        if key.lower() in folder_name.lower():
            return value
    return "movie"  # Default to movie if unknown

libraries = []
seen_names = set()
for entry in os.scandir(cinesync_media_root):
    if entry.is_dir():
        lib_type = guess_library_type(entry.name)
        if entry.name not in seen_names:
            libraries.append({
                "name": entry.name,
                "type": lib_type,
                "location": entry.path
            })
            seen_names.add(entry.name)

with open(output_json_path, "w") as f:
    json.dump(libraries, f, indent=2)

print(f"Generated {output_json_path} with {len(libraries)} libraries.")
