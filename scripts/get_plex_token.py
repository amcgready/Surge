# This script reads PLEX_USERNAME and PLEX_PASSWORD from environment variables.
# If not set, it will prompt the user.
import os
import requests

def get_credentials():
    username = os.environ.get("PLEX_USERNAME")
    password = os.environ.get("PLEX_PASSWORD")
    if not username:
        username = input("Enter your Plex username/email: ")
    if not password:
        import getpass
        password = getpass.getpass("Enter your Plex password: ")
    return username, password

def get_plex_token(username, password):
    url = "https://plex.tv/users/sign_in.json"
    headers = {
        "X-Plex-Client-Identifier": "GetPlexTokenScript",
        "X-Plex-Product": "GetPlexTokenScript",
        "X-Plex-Version": "1.0",
        "X-Plex-Device": "Script",
        "X-Plex-Platform": "Python"
    }
    data = {
        "user[login]": username,
        "user[password]": password
    }
    response = requests.post(url, headers=headers, data=data)
    if response.status_code == 201:
        token = response.json()["user"]["authentication_token"]
        print(f"Plex Token: {token}")
        return token
    else:
        print("Failed to get Plex token. Check your credentials.")
        return None

def get_plex_libraries(plex_url, plex_token):
    url = f"{plex_url}/library/sections"
    headers = {
        "X-Plex-Token": plex_token
    }
    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            from xml.etree import ElementTree
            root = ElementTree.fromstring(response.content)
            print("\nPlex Libraries:")
            for directory in root.findall(".//Directory"):
                title = directory.attrib.get("title")
                key = directory.attrib.get("key")
                print(f"  {title}: {key}")
        else:
            print("Failed to get libraries. Check your Plex URL and token.")
    except Exception as e:
        print(f"Error fetching libraries: {e}")

if __name__ == "__main__":
    # Set your Plex server URL here (e.g., http://localhost:32400)
    PLEX_URL = "http://localhost:32400"
    username, password = get_credentials()
    token = get_plex_token(username, password)
    if token:
        get_plex_libraries(PLEX_URL, token)