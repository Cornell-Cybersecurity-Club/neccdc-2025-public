#!/usr/bin/env python3
"""
Practice Environment Setup Script for NECCDC 2025
Generates inventory for single team (team 0) and runs all post-configuration playbooks
"""

import yaml
import subprocess
import os
import sys

def generate_practice_inventory():
    """Generate inventory for single practice team (team 0)"""
    print("🔧 Generating practice inventory for team 0...")
    
    inventory = {
        "ctrl_plane": {
            "hosts": {
                "10.0.0.250": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "ctrl-plane"
            }
        },
        "database": {
            "hosts": {
                "10.0.0.196": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "database"
            }
        },
        "firewall": {
            "hosts": {
                "10.255.0.254": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "firewall"
            }
        },
        "graylog": {
            "hosts": {
                "10.0.0.169": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "graylog"
            }
        },
        "teleport": {
            "hosts": {
                "10.0.0.180": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "teleport"
            }
        },
        "node_0": {
            "hosts": {
                "10.0.0.200": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "node-0"
            }
        },
        "node_1": {
            "hosts": {
                "10.0.0.211": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "node-1"
            }
        },
        "node_2": {
            "hosts": {
                "10.0.0.222": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "node-2"
            }
        },
        "windows_ca": {
            "hosts": {
                "10.0.0.32": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "ca-01"
            }
        },
        "windows_dc": {
            "hosts": {
                "10.0.0.4": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "dc-01"
            }
        },
        "windows_dc_2": {
            "hosts": {
                "10.0.0.120": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "dc-02"
            }
        },
        "windows_workstation": {
            "hosts": {
                "10.0.0.67": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "win-01"
            }
        },
        "windows_workstation_2": {
            "hosts": {
                "10.0.0.76": {
                    "team": 0
                }
            },
            "vars": {
                "hostname": "win-02"
            }
        }
    }
    
    # Write inventory file
    inventory_dir = os.path.join(os.path.dirname(__file__), 'inventory')
    inventory_file = os.path.join(inventory_dir, '0-inventory.yaml')
    
    with open(inventory_file, 'w') as file:
        yaml.dump(inventory, file, default_flow_style=False)
    
    print(f"✅ Practice inventory generated: {inventory_file}")
    return inventory_file

def run_ansible_playbook(playbook_path, description):
    """Run an Ansible playbook with error handling"""
    print(f"\n🚀 {description}")
    print(f"   Running: {playbook_path}")
    
    try:
        result = subprocess.run([
            'ansible-playbook', 
            playbook_path,
            '--inventory', 
            'inventory/',
            '-v'
        ], 
        check=True, 
        capture_output=True, 
        text=True,
        cwd=os.path.dirname(__file__)
        )
        print(f"✅ {description} - SUCCESS")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - FAILED")
        print(f"   Error: {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"❌ {description} - PLAYBOOK NOT FOUND: {playbook_path}")
        return False

def setup_practice_environment():
    """Main function to setup practice environment"""
    print("🏁 NECCDC 2025 Practice Environment Setup")
    print("=========================================")
    
    # Change to regionals directory
    regionals_dir = os.path.dirname(__file__)
    os.chdir(regionals_dir)
    print(f"📁 Working directory: {os.getcwd()}")
    
    # Generate inventory
    generate_practice_inventory()
    
    # Post-configuration playbooks to run
    playbooks = [
        {
            'path': 'post/database/playbook.yaml',
            'description': 'Configuring Database Server (InfluxDB + Teleport)'
        },
        {
            'path': 'post/graylog/playbook.yaml', 
            'description': 'Configuring Graylog Server (Logging + SIEM)'
        },
        {
            'path': 'post/teleport/playbook.yaml',
            'description': 'Configuring Teleport Server (Access Gateway)'
        },
        {
            'path': 'post/kubernetes/playbook.yaml',
            'description': 'Configuring Kubernetes Control Plane'
        },
        {
            'path': 'post/kubernetes/post.yaml',
            'description': 'Configuring Kubernetes Post-Setup (Services)'
        },
        {
            'path': 'post/pfsense/playbook.yaml',
            'description': 'Configuring pfSense Firewall'
        },
        {
            'path': 'post/windows/playbook.yaml',
            'description': 'Configuring Windows Domain Controllers'
        }
    ]
    
    # Track results
    successful = []
    failed = []
    
    # Run each playbook
    for playbook in playbooks:
        playbook_path = playbook['path']
        description = playbook['description']
        
        # Check if playbook exists
        if os.path.exists(playbook_path):
            if run_ansible_playbook(playbook_path, description):
                successful.append(playbook['description'])
            else:
                failed.append(playbook['description'])
        else:
            print(f"⚠️  SKIPPED: {description} (playbook not found)")
            failed.append(f"{description} (not found)")
    
    # Summary
    print("\n" + "="*60)
    print("🏁 PRACTICE ENVIRONMENT SETUP COMPLETE")
    print("="*60)
    
    if successful:
        print(f"\n✅ SUCCESSFUL CONFIGURATIONS ({len(successful)}):")
        for item in successful:
            print(f"   • {item}")
    
    if failed:
        print(f"\n❌ FAILED CONFIGURATIONS ({len(failed)}):")
        for item in failed:
            print(f"   • {item}")
    
    print(f"\n📊 SUMMARY: {len(successful)} successful, {len(failed)} failed")
    
    if failed:
        print("\n⚠️  Some configurations failed. Check the error messages above.")
        print("   You may need to:")
        print("   1. Verify all EC2 instances are running")
        print("   2. Check SSH connectivity to instances")
        print("   3. Ensure security groups allow SSH (port 22)")
        return False
    else:
        print("\n🎉 All configurations completed successfully!")
        print("   Your practice environment is ready!")
        return True

if __name__ == "__main__":
    success = setup_practice_environment()
    sys.exit(0 if success else 1)