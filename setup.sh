#!/bin/bash
# NECCDC 2025 - Complete Environment Setup Script for Linux/macOS
# This script installs all required tools to deploy the CCDC infrastructure

set -e  # Exit on error

echo "=== NECCDC 2025 Environment Setup ==="
echo "This script will install all required tools for deployment"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/redhat-release ]; then
        DISTRO="redhat"
    else
        DISTRO="unknown"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo -e "${RED}[ERROR] Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${CYAN}Detected OS: $OS${NC}"
echo ""

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew (macOS)
install_homebrew() {
    if command_exists brew; then
        echo -e "${GREEN}[OK] Homebrew is already installed${NC}"
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if command_exists brew; then
        echo -e "${GREEN}[OK] Homebrew installed successfully${NC}"
    else
        echo -e "${RED}[ERROR] Homebrew installation failed${NC}"
        exit 1
    fi
}

# Update package manager
update_package_manager() {
    if [ "$OS" == "macos" ]; then
        echo -e "${YELLOW}[UPDATING] Homebrew...${NC}"
        brew update
    elif [ "$DISTRO" == "debian" ]; then
        echo -e "${YELLOW}[UPDATING] apt...${NC}"
        sudo apt-get update
    elif [ "$DISTRO" == "redhat" ]; then
        echo -e "${YELLOW}[UPDATING] yum...${NC}"
        sudo yum update -y
    fi
}

# Install AWS CLI
install_aws_cli() {
    if command_exists aws; then
        echo -e "${GREEN}[OK] AWS CLI is already installed${NC}"
        aws --version
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] AWS CLI...${NC}"
    
    if [ "$OS" == "macos" ]; then
        brew install awscli
    elif [ "$OS" == "linux" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    fi
    
    if command_exists aws; then
        echo -e "${GREEN}[OK] AWS CLI installed successfully${NC}"
        aws --version
    else
        echo -e "${RED}[ERROR] AWS CLI installation failed${NC}"
        exit 1
    fi
}

# Install Terraform
install_terraform() {
    if command_exists terraform; then
        version=$(terraform version -json | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)
        echo -e "${GREEN}[OK] Terraform is already installed (version $version)${NC}"
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] Terraform...${NC}"
    
    if [ "$OS" == "macos" ]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    elif [ "$DISTRO" == "debian" ]; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install terraform -y
    elif [ "$DISTRO" == "redhat" ]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        sudo yum -y install terraform
    fi
    
    if command_exists terraform; then
        echo -e "${GREEN}[OK] Terraform installed successfully${NC}"
        terraform version
    else
        echo -e "${RED}[ERROR] Terraform installation failed${NC}"
        exit 1
    fi
}

# Install Git
install_git() {
    if command_exists git; then
        echo -e "${GREEN}[OK] Git is already installed${NC}"
        git --version
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] Git...${NC}"
    
    if [ "$OS" == "macos" ]; then
        brew install git
    elif [ "$DISTRO" == "debian" ]; then
        sudo apt-get install git -y
    elif [ "$DISTRO" == "redhat" ]; then
        sudo yum install git -y
    fi
    
    if command_exists git; then
        echo -e "${GREEN}[OK] Git installed successfully${NC}"
    else
        echo -e "${RED}[ERROR] Git installation failed${NC}"
        exit 1
    fi
}

# Install Session Manager Plugin
install_session_manager_plugin() {
    if command_exists session-manager-plugin; then
        echo -e "${GREEN}[OK] AWS Session Manager Plugin is already installed${NC}"
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] AWS Session Manager Plugin...${NC}"
    
    if [ "$OS" == "macos" ]; then
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
        unzip sessionmanager-bundle.zip
        sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
        rm -rf sessionmanager-bundle sessionmanager-bundle.zip
    elif [ "$OS" == "linux" ]; then
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
        sudo dpkg -i session-manager-plugin.deb
        rm session-manager-plugin.deb
    fi
    
    if command_exists session-manager-plugin; then
        echo -e "${GREEN}[OK] Session Manager Plugin installed successfully${NC}"
    else
        echo -e "${YELLOW}[WARNING] Session Manager Plugin installation may have failed${NC}"
    fi
}

# Install Python and pip
install_python() {
    if command_exists python3; then
        echo -e "${GREEN}[OK] Python 3 is already installed${NC}"
        python3 --version
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] Python 3...${NC}"
    
    if [ "$OS" == "macos" ]; then
        brew install python3
    elif [ "$DISTRO" == "debian" ]; then
        sudo apt-get install python3 python3-pip -y
    elif [ "$DISTRO" == "redhat" ]; then
        sudo yum install python3 python3-pip -y
    fi
    
    if command_exists python3; then
        echo -e "${GREEN}[OK] Python 3 installed successfully${NC}"
    else
        echo -e "${RED}[ERROR] Python 3 installation failed${NC}"
        exit 1
    fi
}

# Install Ansible
install_ansible() {
    if command_exists ansible; then
        echo -e "${GREEN}[OK] Ansible is already installed${NC}"
        ansible --version | head -n 1
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] Ansible via pip...${NC}"
    
    if [ "$OS" == "macos" ]; then
        brew install ansible
    else
        python3 -m pip install --user ansible
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
    
    if command_exists ansible; then
        echo -e "${GREEN}[OK] Ansible installed successfully${NC}"
        ansible --version | head -n 1
    else
        echo -e "${YELLOW}[WARNING] Ansible installation may have failed${NC}"
    fi
}

# Install OpenSSH
install_openssh() {
    if command_exists ssh; then
        echo -e "${GREEN}[OK] OpenSSH is already installed${NC}"
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] OpenSSH...${NC}"
    
    if [ "$DISTRO" == "debian" ]; then
        sudo apt-get install openssh-client -y
    elif [ "$DISTRO" == "redhat" ]; then
        sudo yum install openssh-clients -y
    fi
    
    echo -e "${GREEN}[OK] OpenSSH installed${NC}"
}

# Install unzip (needed for AWS CLI)
install_unzip() {
    if command_exists unzip; then
        return
    fi
    
    echo -e "${YELLOW}[INSTALLING] unzip...${NC}"
    
    if [ "$OS" == "macos" ]; then
        brew install unzip
    elif [ "$DISTRO" == "debian" ]; then
        sudo apt-get install unzip -y
    elif [ "$DISTRO" == "redhat" ]; then
        sudo yum install unzip -y
    fi
}

# Check .env file
check_env_file() {
    echo ""
    echo -e "${CYAN}=== Checking Environment Configuration ===${NC}"
    
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}[ACTION REQUIRED] .env file not found!${NC}"
        echo -e "${GRAY}  1. Copy .env.example to .env${NC}"
        echo -e "${GRAY}  2. Edit .env and fill in your values:${NC}"
        echo -e "${GRAY}     - WIREGUARD_PASSWORD: A secure password for the VPN web UI${NC}"
        echo -e "${GRAY}     - WIREGUARD_PUBLIC_IP: Your Wireguard EC2 instance public IP (after deployment)${NC}"
        echo ""
        echo -e "${YELLOW}Run this command to create .env from template:${NC}"
        echo -e "${NC}  cp .env.example .env${NC}"
    else
        echo -e "${GREEN}[OK] .env file exists${NC}"
        
        if grep -q "your-secure-password-here" .env || grep -q "your-wireguard-public-ip" .env; then
            echo -e "${YELLOW}[WARNING] .env file contains placeholder values!${NC}"
            echo -e "${GRAY}  Edit .env and replace placeholder values with real ones${NC}"
        else
            echo -e "${GREEN}[OK] .env file appears to be configured${NC}"
        fi
    fi
}

# Main installation sequence
echo ""
echo -e "${CYAN}Starting installation...${NC}"
echo ""

if [ "$OS" == "macos" ]; then
    install_homebrew
    echo ""
fi

update_package_manager
echo ""

install_unzip
echo ""

install_git
echo ""

install_aws_cli
echo ""

install_terraform
echo ""

install_session_manager_plugin
echo ""

install_python
echo ""

install_ansible
echo ""

install_openssh
echo ""

# AWS Configuration Check
echo -e "${CYAN}=== AWS Configuration ===${NC}"
if command_exists aws; then
    if aws sts get-caller-identity --profile neccdc-2025 >/dev/null 2>&1; then
        echo -e "${GREEN}[OK] AWS credentials are configured (profile: neccdc-2025)${NC}"
    else
        echo -e "${YELLOW}[ACTION REQUIRED] AWS credentials not configured!${NC}"
        echo -e "${GRAY}  Run: aws configure --profile neccdc-2025${NC}"
        echo -e "${GRAY}  You'll need:${NC}"
        echo -e "${GRAY}    - AWS Access Key ID${NC}"
        echo -e "${GRAY}    - AWS Secret Access Key${NC}"
        echo -e "${GRAY}    - Default region (us-east-2)${NC}"
    fi
fi
echo ""

# Environment file check
check_env_file
echo ""

# Summary
echo -e "${CYAN}=== Installation Summary ===${NC}"
echo -e "${GREEN}[✓] Git${NC}"
echo -e "${GREEN}[✓] AWS CLI${NC}"
echo -e "${GREEN}[✓] Terraform${NC}"
echo -e "${GREEN}[✓] AWS Session Manager Plugin${NC}"
echo -e "${GREEN}[✓] Python 3${NC}"
echo -e "${GREEN}[✓] Ansible${NC}"
echo -e "${GREEN}[✓] OpenSSH${NC}"
echo ""

echo -e "${CYAN}=== Next Steps ===${NC}"
echo -e "${NC}1. Configure AWS credentials:${NC}"
echo -e "${GRAY}   aws configure --profile neccdc-2025${NC}"
echo ""
echo -e "${NC}2. Create and configure .env file:${NC}"
echo -e "${GRAY}   cp .env.example .env${NC}"
echo -e "${GRAY}   nano .env  # Fill in your values${NC}"
echo ""
echo -e "${NC}3. Create S3 bucket for Terraform state:${NC}"
echo -e "${GRAY}   aws s3 mb s3://YOUR-BUCKET-NAME --profile neccdc-2025 --region us-east-2${NC}"
echo ""
echo -e "${NC}4. Update terraform settings.tf with your bucket name${NC}"
echo ""
echo -e "${NC}5. Generate SSH keypair:${NC}"
echo -e "${GRAY}   ssh-keygen -t rsa -b 4096 -f documentation/black_team/black-team -N ''${NC}"
echo ""
echo -e "${NC}6. Deploy black team infrastructure:${NC}"
echo -e "${GRAY}   cd terraform/regionals/environments/black${NC}"
echo -e "${GRAY}   terraform init${NC}"
echo -e "${GRAY}   terraform apply${NC}"
echo ""
echo -e "${GREEN}Setup complete! Check the README.md for full deployment instructions.${NC}"
echo ""
