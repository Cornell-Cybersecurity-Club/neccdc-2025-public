# NECCDC 2025 - Complete Environment Setup Script for Windows
# This script installs all required tools to deploy the CCDC infrastructure

Write-Host "=== NECCDC 2025 Environment Setup ===" -ForegroundColor Cyan
Write-Host "This script will install all required tools for deployment" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Function to install Chocolatey
function Install-Chocolatey {
    if (Test-CommandExists choco) {
        Write-Host "[OK] Chocolatey is already installed" -ForegroundColor Green
        return
    }
    
    Write-Host "[INSTALLING] Chocolatey package manager..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    if (Test-CommandExists choco) {
        Write-Host "[OK] Chocolatey installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Chocolatey installation failed" -ForegroundColor Red
        exit 1
    }
}

# Function to install AWS CLI
function Install-AWSCLI {
    if (Test-CommandExists aws) {
        Write-Host "[OK] AWS CLI is already installed" -ForegroundColor Green
        aws --version
        return
    }
    
    Write-Host "[INSTALLING] AWS CLI..." -ForegroundColor Yellow
    choco install awscli -y
    refreshenv
    
    if (Test-CommandExists aws) {
        Write-Host "[OK] AWS CLI installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] AWS CLI installation failed" -ForegroundColor Red
        exit 1
    }
}

# Function to install Terraform
function Install-Terraform {
    if (Test-CommandExists terraform) {
        $version = terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version
        Write-Host "[OK] Terraform is already installed (version $version)" -ForegroundColor Green
        return
    }
    
    Write-Host "[INSTALLING] Terraform..." -ForegroundColor Yellow
    choco install terraform -y
    refreshenv
    
    if (Test-CommandExists terraform) {
        Write-Host "[OK] Terraform installed successfully" -ForegroundColor Green
        terraform version
    } else {
        Write-Host "[ERROR] Terraform installation failed" -ForegroundColor Red
        exit 1
    }
}

# Function to install Git
function Install-Git {
    if (Test-CommandExists git) {
        Write-Host "[OK] Git is already installed" -ForegroundColor Green
        git --version
        return
    }
    
    Write-Host "[INSTALLING] Git..." -ForegroundColor Yellow
    choco install git -y
    refreshenv
    
    if (Test-CommandExists git) {
        Write-Host "[OK] Git installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Git installation failed" -ForegroundColor Red
        exit 1
    }
}

# Function to install Session Manager Plugin
function Install-SessionManagerPlugin {
    $pluginPath = "$env:ProgramFiles\Amazon\SessionManagerPlugin\bin\session-manager-plugin.exe"
    if (Test-Path $pluginPath) {
        Write-Host "[OK] AWS Session Manager Plugin is already installed" -ForegroundColor Green
        return
    }
    
    Write-Host "[INSTALLING] AWS Session Manager Plugin..." -ForegroundColor Yellow
    $installerUrl = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe"
    $installerPath = "$env:TEMP\SessionManagerPluginSetup.exe"
    
    Write-Host "  Downloading installer..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    
    Write-Host "  Running installer..." -ForegroundColor Gray
    Start-Process -FilePath $installerPath -Args "/quiet" -Wait
    
    Remove-Item $installerPath -Force
    
    if (Test-Path $pluginPath) {
        Write-Host "[OK] Session Manager Plugin installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Session Manager Plugin installation may have failed" -ForegroundColor Yellow
    }
}

# Function to install Python (required for Ansible)
function Install-Python {
    if (Test-CommandExists python) {
        Write-Host "[OK] Python is already installed" -ForegroundColor Green
        python --version
        return
    }
    
    Write-Host "[INSTALLING] Python 3..." -ForegroundColor Yellow
    choco install python -y
    refreshenv
    
    if (Test-CommandExists python) {
        Write-Host "[OK] Python installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Python installation failed" -ForegroundColor Red
        exit 1
    }
}

# Function to install Ansible
function Install-Ansible {
    if (Test-CommandExists ansible) {
        Write-Host "[OK] Ansible is already installed" -ForegroundColor Green
        ansible --version
        return
    }
    
    Write-Host "[INSTALLING] Ansible via pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip
    python -m pip install ansible
    
    if (Test-CommandExists ansible) {
        Write-Host "[OK] Ansible installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Ansible installation may have failed (Windows compatibility issues are common)" -ForegroundColor Yellow
        Write-Host "  Note: You can use AWS Session Manager instead of Ansible for most tasks" -ForegroundColor Gray
    }
}

# Function to install OpenSSH Client
function Install-OpenSSH {
    $sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
    
    if ($sshClient.State -eq "Installed") {
        Write-Host "[OK] OpenSSH Client is already installed" -ForegroundColor Green
        return
    }
    
    Write-Host "[INSTALLING] OpenSSH Client..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Write-Host "[OK] OpenSSH Client installed successfully" -ForegroundColor Green
}

# Function to verify .env setup
function Check-EnvFile {
    Write-Host ""
    Write-Host "=== Checking Environment Configuration ===" -ForegroundColor Cyan
    
    if (-not (Test-Path ".env")) {
        Write-Host "[ACTION REQUIRED] .env file not found!" -ForegroundColor Yellow
        Write-Host "  1. Copy .env.example to .env" -ForegroundColor Gray
        Write-Host "  2. Edit .env and fill in your values:" -ForegroundColor Gray
        Write-Host "     - WIREGUARD_PASSWORD: A secure password for the VPN web UI" -ForegroundColor Gray
        Write-Host "     - WIREGUARD_PUBLIC_IP: Your Wireguard EC2 instance public IP (after deployment)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Run this command to create .env from template:" -ForegroundColor Yellow
        Write-Host "  Copy-Item .env.example .env" -ForegroundColor White
    } else {
        Write-Host "[OK] .env file exists" -ForegroundColor Green
        
        # Check if values are filled in
        $envContent = Get-Content .env -Raw
        if ($envContent -match "your-secure-password-here" -or $envContent -match "your-wireguard-public-ip") {
            Write-Host "[WARNING] .env file contains placeholder values!" -ForegroundColor Yellow
            Write-Host "  Edit .env and replace placeholder values with real ones" -ForegroundColor Gray
        } else {
            Write-Host "[OK] .env file appears to be configured" -ForegroundColor Green
        }
    }
}

# Main installation sequence
Write-Host ""
Write-Host "Starting installation..." -ForegroundColor Cyan
Write-Host ""

Install-Chocolatey
Write-Host ""

Install-Git
Write-Host ""

Install-AWSCLI
Write-Host ""

Install-Terraform
Write-Host ""

Install-SessionManagerPlugin
Write-Host ""

Install-Python
Write-Host ""

Install-Ansible
Write-Host ""

Install-OpenSSH
Write-Host ""

# AWS Configuration Check
Write-Host "=== AWS Configuration ===" -ForegroundColor Cyan
if (Test-CommandExists aws) {
    $awsConfigured = $false
    try {
        $identity = aws sts get-caller-identity --profile neccdc-2025 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] AWS credentials are configured (profile: neccdc-2025)" -ForegroundColor Green
            $awsConfigured = $true
        }
    } catch {}
    
    if (-not $awsConfigured) {
        Write-Host "[ACTION REQUIRED] AWS credentials not configured!" -ForegroundColor Yellow
        Write-Host "  Run: aws configure --profile neccdc-2025" -ForegroundColor Gray
        Write-Host "  You'll need:" -ForegroundColor Gray
        Write-Host "    - AWS Access Key ID" -ForegroundColor Gray
        Write-Host "    - AWS Secret Access Key" -ForegroundColor Gray
        Write-Host "    - Default region (us-east-2)" -ForegroundColor Gray
    }
}
Write-Host ""

# Environment file check
Check-EnvFile
Write-Host ""

# Summary
Write-Host "=== Installation Summary ===" -ForegroundColor Cyan
Write-Host "[✓] Chocolatey Package Manager" -ForegroundColor Green
Write-Host "[✓] Git" -ForegroundColor Green
Write-Host "[✓] AWS CLI" -ForegroundColor Green
Write-Host "[✓] Terraform" -ForegroundColor Green
Write-Host "[✓] AWS Session Manager Plugin" -ForegroundColor Green
Write-Host "[✓] Python 3" -ForegroundColor Green
Write-Host "[✓] Ansible (if installation succeeded)" -ForegroundColor Green
Write-Host "[✓] OpenSSH Client" -ForegroundColor Green
Write-Host ""

Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Configure AWS credentials:" -ForegroundColor White
Write-Host "   aws configure --profile neccdc-2025" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Create and configure .env file:" -ForegroundColor White
Write-Host "   Copy-Item .env.example .env" -ForegroundColor Gray
Write-Host "   notepad .env  # Fill in your values" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Create S3 bucket for Terraform state:" -ForegroundColor White
Write-Host "   aws s3 mb s3://YOUR-BUCKET-NAME --profile neccdc-2025 --region us-east-2" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Update terraform settings.tf with your bucket name" -ForegroundColor White
Write-Host ""
Write-Host "5. Generate SSH keypair:" -ForegroundColor White
Write-Host "   ssh-keygen -t rsa -b 4096 -f documentation/black_team/black-team -N ''" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Deploy black team infrastructure:" -ForegroundColor White
Write-Host "   cd terraform/regionals/environments/black" -ForegroundColor Gray
Write-Host "   terraform init" -ForegroundColor Gray
Write-Host "   terraform apply" -ForegroundColor Gray
Write-Host ""
Write-Host "Setup complete! Check the README.md for full deployment instructions." -ForegroundColor Green
Write-Host ""
