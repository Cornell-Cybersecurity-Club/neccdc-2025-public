import csv
import yaml

def csv_to_yaml():
    users = []
    
    with open('users.csv', 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            user = {
                'username': row['username'] if 'username' in row else '',
                'first_name': row['name'] if 'name' in row else '',
                'last_name': row['lastName'] if 'lastName' in row else '',
                'email': row['email'] if 'email' in row else '',
                'password': row['password'] if 'password' in row else '',
                'department': row.get('department', 'MISSING'),
                'position': row.get('position', 'MISSING')
            }
            users.append(user)
    
    yaml_data = {'users': users}
    
    with open('employees.yaml', 'w') as yamlfile:
        yaml.safe_dump(yaml_data, yamlfile, sort_keys=False, default_flow_style=False)

if __name__ == '__main__':
    csv_to_yaml()
