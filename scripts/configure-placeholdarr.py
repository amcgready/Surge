#!/usr/bin/env python3
"""
configure-placeholdarr.py
Sets up Placeholdarr and configures .env for download paths.
"""
import os
import sys
import subprocess
from pathlib import Path
from placeholdarr_env_template import ENV_FIELDS

# Check STORAGE_PATH environment variable
STORAGE_PATH = os.environ.get('STORAGE_PATH')
if not STORAGE_PATH:
    print("STORAGE_PATH is not set. Please export STORAGE_PATH and rerun.")
    sys.exit(1)

placeholdarr_dir = os.path.join(STORAGE_PATH, "Placeholdarr")
downloads_tv = os.path.join(STORAGE_PATH, "downloads", "Placeholdarr", "tv")
downloads_movies = os.path.join(STORAGE_PATH, "downloads", "Placeholdarr", "movies")

# Clone Placeholdarr repo if not present
if not os.path.isdir(placeholdarr_dir):
    subprocess.run([
        "git", "clone", "https://github.com/TheIndieArmy/placeholdarr.git", placeholdarr_dir
    ], check=True)
else:
    print("Placeholdarr repo already exists. Skipping clone.")

# Create download folders
os.makedirs(downloads_tv, exist_ok=True)
os.makedirs(downloads_movies, exist_ok=True)

# Copy coming_soon_dummy.mp4 from assets to Placeholdarr as both dummy files
assets_dummy = os.path.join(Path(__file__).parent.parent, "assets", "coming_soon_dummy.mp4")
target_dummy = os.path.join(placeholdarr_dir, "dummy.mp4")
target_coming_soon = os.path.join(placeholdarr_dir, "coming_soon_dummy.mp4")
import shutil
if os.path.exists(assets_dummy):
    shutil.copy2(assets_dummy, target_dummy)
    shutil.copy2(assets_dummy, target_coming_soon)
else:
    print(f"Warning: {assets_dummy} not found. Dummy video files not copied.")

# Write .env file for Placeholdarr

# Fill in ENV_FIELDS with values from environment or sensible defaults
env_path = os.path.join(placeholdarr_dir, ".env")
env_vars = ENV_FIELDS.copy()
env_vars["MOVIE_LIBRARY_FOLDER"] = os.path.join(STORAGE_PATH, "downloads", "CineSync", "Movies")
env_vars["TV_LIBRARY_FOLDER"] = os.path.join(STORAGE_PATH, "downloads", "CineSync", "TV Series")
env_vars["DUMMY_FILE_PATH"] = os.path.join(placeholdarr_dir, "dummy.mp4")
env_vars["COMING_SOON_DUMMY_FILE_PATH"] = os.path.join(placeholdarr_dir, "coming_soon_dummy.mp4")

# Optionally fill in from environment variables if present
for key in env_vars:
    if key in os.environ:
        env_vars[key] = os.environ[key]
    else:
        # Try to read from main .env file if not set in environment
        main_env_path = Path(__file__).parent.parent / ".env"
        if main_env_path.exists():
            with open(main_env_path, "r", encoding="utf-8") as main_env:
                for line in main_env:
                    if line.strip().startswith(f"{key}="):
                        env_value = line.strip().split("=", 1)[1]
                        env_vars[key] = env_value.strip().strip('"').strip("'")
                        break

with open(env_path, "w") as env_file:
    for key, value in env_vars.items():
        env_file.write(f"{key}={value}\n")

print("Placeholdarr and download folders configured.")
