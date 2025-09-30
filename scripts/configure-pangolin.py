

import os
import sys
import yaml
import subprocess
import shutil

# Get storage path from env or argument
storage_path = os.environ.get('STORAGE_PATH') or (sys.argv[1] if len(sys.argv) > 1 else '/opt/surge')
pangolin_dir = os.path.join(storage_path, 'Pangolin')
config_dir = os.path.join(pangolin_dir, 'config')
config_path = os.path.join(config_dir, 'config.yml')

# Clone Pangolin repo
def clone_pangolin_repo(repo_url, target_dir):
    if os.path.exists(target_dir):
        print(f"[INFO] Removing existing Pangolin directory: {target_dir}")
        shutil.rmtree(target_dir)
    print(f"[INFO] Cloning Pangolin repo to {target_dir}")
    subprocess.run(['git', 'clone', repo_url, target_dir], check=True)

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
        'external_port': 3003,
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

def create_config():
    os.makedirs(config_dir, exist_ok=True)
    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False)
    print(f"[SUCCESS] Pangolin config generated at {config_path}")

# Extract Pangolin setup token from docker logs

import re

if __name__ == "__main__":
    # Step 1: Clone Pangolin repo
    pangolin_repo_url = "https://github.com/fosrl/pangolin.git"  # Update if needed
    clone_pangolin_repo(pangolin_repo_url, pangolin_dir)
    # Step 2: Create custom config
    create_config()
