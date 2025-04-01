import yaml

# Team range
start_team = 0
end_team = 19

inventory = {
    "ctrl_plane": {
        "hosts": {
            f"10.0.{(team * 4) + 2}.255": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "ctrl-plane"
        }
    },
    "database": {
        "hosts": {
            f"10.0.{(team * 4) + 3}.192": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "database"
        }
    },
    "firewall": {
        "hosts": {
            f"10.0.{(team * 4)}.10": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "firewall"
        }
    },
    "graylog": {
        "hosts": {
            f"10.0.{team * 4}.247": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "graylog"
        }
    },
    "nginx": {
        "hosts": {
            f"10.0.{team * 4}.200": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "nginx"
        }
    },
    "node_1": {
        "hosts": {
            f"10.0.{(team * 4) + 3}.0": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "node-1"
        }
    },
    "node_2": {
        "hosts": {
            f"10.0.{(team * 4) + 3}.77": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "node-2"
        }
    },
    "node_3": {
        "hosts": {
            f"10.0.{(team * 4) + 2}.5": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "node-3"
        }
    },
    "windows_ca": {
        "hosts": {
            f"10.0.{team * 4}.138": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "ca-01"
        }
    },
    "windows_dc": {
        "hosts": {
            f"10.0.{(team * 4) + 2}.77": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "dc-01"
        }
    },
    "windows_workstation": {
        "hosts": {
            f"10.0.{(team * 4) + 2}.128": {
                "team": team
            }
            for team in range(start_team, end_team + 1)
        },
        "vars": {
            "hostname": "win-01"
        }
    },
}

with open('0-inventory.yaml', 'w') as file:
    yaml.dump(inventory, file, default_flow_style=False)
