# Note the users returned by the API can have special
# characters in their names or spaces in last names
# Passwords can be weird audit them...

import requests
import yaml
import os

domain = "placebo-pharma.com"
output_file = "users.yaml"

def fetch_random_user():
    url = 'https://randomuser.me/api/'
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        user = data['results'][0]
        
        username = f"{user['name']['first']}.{user['name']['last']}".lower()

        # Extract user information
        user_info = {
            'department': "MISSING",
            'email': f"{username}@{domain}",
            'first_name': user['name']['first'],
            'last_name': user['name']['last'],
            'password': user['login']['password'],
            'position': "MISSING",
            'username': username,
        }
        
        # Read existing data or create new structure
        if os.path.exists(output_file):
            with open(output_file, 'r') as f:
                users_data = yaml.safe_load(f) or {'users': []}
        else:
            users_data = {'users': []}
        
        # Append new user
        users_data['users'].append(user_info)
        
        # Write to YAML file
        with open(output_file, 'w') as f:
            yaml.dump(users_data, f, default_flow_style=False)
        
        print("User data has been appended to users.yaml")
    else:
        print(f"Failed to fetch data. Status code: {response.status_code}")

if __name__ == "__main__":
    for i in range(50):
      fetch_random_user()
