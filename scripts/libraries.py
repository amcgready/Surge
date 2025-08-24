#!/usr/bin/env python3
"""
libraries.py - Post-deployment script to create missing library folders (e.g., 4k separation, kids separation)
Run with: ./surge library
"""
import subprocess
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def run_script(script_name):
    script_path = os.path.join(SCRIPT_DIR, script_name)
    print(f"Running {script_name}...")
    result = subprocess.run(["python3", script_path], capture_output=True, text=True)
    print(result.stdout)
    if result.returncode != 0:
        print(result.stderr)
        raise RuntimeError(f"{script_name} failed with exit code {result.returncode}")

if __name__ == "__main__":
    run_script("generate_libraries_json.py")
    run_script("plex_create_libraries.py")
    print("Library setup complete.")
