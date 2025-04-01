import random
import string
import yaml

def generate_password(length=16):
    """Generate a random password alternating between uppercase, number, and lowercase"""
    chars = []
    for i in range(length):
        if i % 3 == 0:
            chars.append(random.choice(string.ascii_uppercase))
        elif i % 3 == 1:
            chars.append(random.choice(string.digits))
        else:
            chars.append(random.choice(string.ascii_lowercase))
    return ''.join(chars)

def generate_teams(num_teams=11):
    """Generate team configurations"""
    teams = []
    for i in range(num_teams):  # Changed to start from 0
        team = {
            'name': f'team{i:02d}',
            'elk_password': generate_password(),
            'overrides': {
                'TeamNumber': i
            }
        }
        teams.append(team)
    return {'teams': teams}

if __name__ == '__main__':
    teams_config = generate_teams()
    print(yaml.dump(teams_config, sort_keys=False))
