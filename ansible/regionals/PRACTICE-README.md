# NECCDC 2025 Practice Environment

This directory contains scripts to set up a single blue team practice environment for NECCDC 2025 competition training.

## Overview

The practice environment provides a simplified deployment for team 0 only, allowing you to:
- Test all competition infrastructure with one team
- Practice incident response and system administration
- Validate AMI builds and configurations
- Train team members on the competition environment

## Prerequisites

Before running the practice setup:

1. **AWS Setup**
   - AWS CLI configured with `neccdc-2025` profile
   - EC2 instances launched from your AMIs
   - Security group `sg-003fd7d2e39c5aca8` configured with proper ports

2. **Local Setup**
   - Python 3 installed
   - Ansible installed: `pip install ansible`
   - SSH key pair for EC2 access

3. **Network Setup**
   - All instances using the practice IP scheme (team 0):
     ```
     Database Server:     10.0.0.196
     Graylog Server:      10.0.0.169  
     Teleport Server:     10.0.0.180
     Kubernetes Control:  10.0.0.250
     Kubernetes Node 0:   10.0.0.200
     Kubernetes Node 1:   10.0.0.211
     Kubernetes Node 2:   10.0.0.222
     Windows DC-01:       10.0.0.4
     Windows DC-02:       10.0.0.120
     Windows CA:          10.0.0.32
     Windows Win-01:      10.0.0.67
     Windows Win-02:      10.0.0.76
     pfSense Firewall:    10.255.0.254
     ```

## Quick Start

### For Windows (PowerShell)
```powershell
cd ansible\regionals
.\setup-practice.ps1
```

### For Linux/macOS (Bash)  
```bash
cd ansible/regionals
chmod +x setup-practice.sh
./setup-practice.sh
```

### Manual Python Execution
```bash
cd ansible/regionals
python3 practice-setup.py
```

## What the Setup Does

1. **Generates Practice Inventory**
   - Creates `inventory/0-inventory.yaml` for team 0
   - Configures all host IP addresses and team variables

2. **Runs Post-Configuration Playbooks**
   - Database: Configures InfluxDB and Teleport agent
   - Graylog: Sets up logging and SIEM services
   - Teleport: Configures access gateway server
   - Kubernetes: Sets up control plane and services
   - pfSense: Configures firewall rules
   - Windows: Sets up domain controllers

3. **Validates Configuration**
   - Checks SSH connectivity to all hosts
   - Reports success/failure for each service
   - Provides troubleshooting guidance

## After Setup

### Service Access URLs
- **InfluxDB Database**: http://10.0.0.196:8086
- **Graylog Web UI**: http://10.0.0.169:9000
- **Teleport Web UI**: https://10.0.0.180:3080
- **Kubernetes API**: https://10.0.0.250:6443

### Default Credentials
- **Linux SSH**: Use your EC2 key pair
- **Windows RDP**: Administrator / (password from AMI)
- **Graylog**: admin / admin
- **Teleport**: Generated during setup

### Testing Your Environment

1. **Database Server**
   ```bash
   ssh -i your-key.pem ec2-user@10.0.0.196
   sudo systemctl status influxdb
   curl http://localhost:8086/health
   ```

2. **Kubernetes Cluster**
   ```bash
   ssh -i your-key.pem ec2-user@10.0.0.250
   sudo kubectl get nodes
   sudo kubectl get pods --all-namespaces
   ```

3. **Windows Domain**
   - RDP to 10.0.0.4 (DC-01)
   - Login as Administrator
   - Check Active Directory Users and Computers

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**
   - Verify security groups allow SSH (port 22)
   - Check that instances are running
   - Validate your SSH key permissions: `chmod 600 your-key.pem`

2. **Ansible Playbook Failures**
   - Ensure all target hosts are accessible
   - Check that AMI builds completed successfully
   - Verify team 0 IP addressing is correct

3. **Service Startup Issues**
   - SSH to the problematic host
   - Check service logs: `sudo journalctl -u service-name`
   - Verify configuration files were templated correctly

### Manual Recovery

If automated setup fails, you can run individual playbooks:

```bash
# Database configuration only
ansible-playbook post/database/playbook.yaml -i inventory/ -v

# Kubernetes configuration only  
ansible-playbook post/kubernetes/playbook.yaml -i inventory/ -v

# Windows domain configuration only
ansible-playbook post/windows/playbook.yaml -i inventory/ -v
```

## Customization

To modify the practice environment:

1. **Change IP Addresses**: Edit the IP mappings in `practice-setup.py`
2. **Add/Remove Services**: Modify the playbook list in the main function
3. **Team Configuration**: The setup uses team 0 - change team variables as needed

## Competition Deployment

This practice setup is a simplified version of the full competition deployment. For the actual competition:
- Use `inventory-generator.py` to create multiple teams (0-10)
- Deploy separate infrastructure per team  
- Enable ScoreStack for automated scoring
- Configure team-specific credentials and challenges