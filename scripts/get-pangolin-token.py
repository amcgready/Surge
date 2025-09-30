import os
import subprocess
import re
import sys

def get_pangolin_setup_token():
    try:
        logs = subprocess.check_output(['docker', 'logs', 'surge-pangolin'], text=True)
        match = re.search(r'Setup Token:\s*([A-Za-z0-9\-_]+)', logs)
        if match:
            return match.group(1)
    except Exception as e:
        print(f"[ERROR] Could not get Pangolin setup token: {e}")
    return None

def save_token_to_env(token, env_path):
    if not token:
        print("[ERROR] No Pangolin setup token found.")
        return
    lines = []
    found = False
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                if line.startswith('PANGOLIN_SETUP_TOKEN='):
                    lines.append(f'PANGOLIN_SETUP_TOKEN={token}\n')
                    found = True
                else:
                    lines.append(line)
    if not found:
        lines.append(f'PANGOLIN_SETUP_TOKEN={token}\n')
    with open(env_path, 'w') as f:
        f.writelines(lines)
    print(f"[SUCCESS] Pangolin setup token saved to {env_path}")

if __name__ == "__main__":
    # Optionally allow .env path as argument
    env_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
    token = get_pangolin_setup_token()
    save_token_to_env(token, env_path)
