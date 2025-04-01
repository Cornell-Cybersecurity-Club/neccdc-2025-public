import yaml
import csv
from pathlib import Path

def read_yaml(file_path):
    with open(file_path, 'r') as yaml_file:
        return yaml.safe_load(yaml_file)

def write_csv(data, output_file):
    if not data or 'users' not in data:
        return
    
    fieldnames = ['username', 'first_name', 'last_name', 'email', 
                  'department', 'position', 'password']
    
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for user in data['users']:
            writer.writerow(user)

def main():
    input_file = Path(__file__).parent / 'users.yaml'
    output_file = Path(__file__).parent / 'users.csv'
    
    yaml_data = read_yaml(input_file)
    write_csv(yaml_data, output_file)

if __name__ == '__main__':
    main()
