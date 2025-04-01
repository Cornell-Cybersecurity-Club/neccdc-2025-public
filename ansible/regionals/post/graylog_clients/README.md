# Graylog Ansible Playbook

This repository contains Ansible playbooks for installing, configuring, and uninstalling Graylog, MongoDB, and related components on both Debian and Windows systems.

## Usage

To configure A Debian-based and/or Windows client, run: `ansible-playbook playbook.yaml` 

 
## Variables

### Client Installer Variables

The following variables are defined in `roles/client_configure/vars/main.yml`: 

SERVER_API_URL: URL for the Graylog API.
SERVER_API_USERNAME: Username for the Graylog API.
SERVER_API_PASSWORD: Password for the Graylog API.
NEW_TOKEN_NAME: Name for the new API token.
