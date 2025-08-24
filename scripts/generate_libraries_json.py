import os
import json
import sys

# Usage: python generate_libraries_json.py <cinesync_media_root> <output_json_path>
if len(sys.argv) != 3:
    print("Usage: generate_libraries_json.py <cinesync_media_root> <output_json_path>")
    sys.exit(1)

cinesync_media_root = sys.argv[1]
output_json_path = sys.argv[2]

# Map folder names to Plex library types
LIBRARY_TYPE_MAP = {
    "Movies": "movie",
    "TV": "show",
    "TV Shows": "show",
    "Music": "music",
    "Photos": "photo",
    # Add more mappings as needed
}

def guess_library_type(folder_name):
    for key, value in LIBRARY_TYPE_MAP.items():
        if key.lower() in folder_name.lower():
            return value
    return "movie"  # Default to movie if unknown

libraries = []
for entry in os.scandir(cinesync_media_root):
    if entry.is_dir():
        lib_type = guess_library_type(entry.name)
        libraries.append({
            "name": entry.name,
            "type": lib_type,
            "location": entry.path
        })

with open(output_json_path, "w") as f:
    json.dump(libraries, f, indent=2)

print(f"Generated {output_json_path} with {len(libraries)} libraries.")
