
import os
import sys
import yaml

# Get storage path from env or argument
storage_path = os.environ.get('STORAGE_PATH') or (sys.argv[1] if len(sys.argv) > 1 else '/opt/surge')
config_dir = os.path.join(storage_path, 'Pangolin', 'config')
config_path = os.path.join(config_dir, 'config.yml')

# Official Pangolin config example
config = {
    'app': {
        'dashboard_url': 'http://localhost:3002',
        'log_level': 'info',
        'save_logs': False
    },
    'domains': {
        'domain1': {
            'base_domain': 'example.com',
            'cert_resolver': 'letsencrypt'
        }
    },
    'server': {
        'external_port': 3000,
        'internal_port': 3001,
        'next_port': 3002,
        'internal_hostname': 'pangolin',
        'session_cookie_name': 'p_session_token',
        'resource_access_token_param': 'p_token',
        'secret': 'your_secret_key_here',
        'resource_access_token_headers': {
            'id': 'P-Access-Token-Id',
            'token': 'P-Access-Token'
        },
        'resource_session_request_param': 'p_session_request'
    },
    'traefik': {
        'http_entrypoint': 'web',
        'https_entrypoint': 'websecure'
    },
    'gerbil': {
        'start_port': 51820,
        'base_endpoint': 'localhost',
        'block_size': 24,
        'site_block_size': 30,
        'subnet_group': '100.89.137.0/20',
        'use_subdomain': True
    },
    'rate_limits': {
        'global': {
            'window_minutes': 1,
            'max_requests': 500
        }
    },
    'flags': {
        'require_email_verification': False,
        'disable_signup_without_invite': True,
        'disable_user_create_org': True,
        'allow_raw_resources': True
    }
}

os.makedirs(config_dir, exist_ok=True)
with open(config_path, 'w') as f:
    yaml.dump(config, f, default_flow_style=False)
print(f"[SUCCESS] Pangolin config generated at {config_path}")

# Extract Pangolin setup token from docker logs
import subprocess
import re

def get_pangolin_setup_token():
    try:
        logs = subprocess.check_output(['docker', 'logs', 'surge-pangolin'], text=True)
        # Adjust regex to match the actual log output for the setup token
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
    # Read .env, replace or append token
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
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
    token = get_pangolin_setup_token()
    save_token_to_env(token, env_path)
