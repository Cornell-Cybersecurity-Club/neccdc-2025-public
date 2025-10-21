# NECCDC 2025 Practice Environment Setup
# PowerShell script for Windows users

param(
    [switch]$Help
)

if ($Help) {
    Write-Host "NECCDC 2025 Practice Environment Setup" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script sets up a single blue team practice environment."
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor Yellow
    Write-Host "  • Python 3 installed"
    Write-Host "  • Ansible installed (pip install ansible)"
    Write-Host "  • AWS CLI configured with neccdc-2025 profile"
    Write-Host "  • EC2 instances launched from AMIs"
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Green
    Write-Host "  .\setup-practice.ps1"
    Write-Host "  .\setup-practice.ps1 -Help"
    exit 0
}

Write-Host "🏁 NECCDC 2025 Practice Environment Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "practice-setup.py")) {
    Write-Host "❌ Error: practice-setup.py not found. Please run this script from the ansible/regionals directory." -ForegroundColor Red
    exit 1
}

# Check if Python 3 is available
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Python not found"
    }
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Python 3 is required but not installed." -ForegroundColor Red
    Write-Host "   Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check if Ansible is available
try {
    $ansibleVersion = ansible-playbook --version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -ne 0) {
        throw "Ansible not found"
    }
    Write-Host "✅ Ansible found: $($ansibleVersion -replace 'ansible-playbook \[core ', '' -replace '\].*', '')" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Ansible is required but not installed." -ForegroundColor Red
    Write-Host "   Install with: pip install ansible" -ForegroundColor Yellow
    exit 1
}

# Check if we have the inventory directory
if (-not (Test-Path "inventory")) {
    Write-Host "❌ Error: inventory directory not found." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Prerequisites check passed" -ForegroundColor Green
Write-Host ""

# Run the Python setup script
Write-Host "🚀 Running practice environment setup..." -ForegroundColor Cyan
try {
    python practice-setup.py
    $setupExitCode = $LASTEXITCODE
} catch {
    $setupExitCode = 1
}

# Check the exit code
if ($setupExitCode -eq 0) {
    Write-Host ""
    Write-Host "🎉 Practice environment setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "   1. Verify all EC2 instances are accessible"
    Write-Host "   2. Test services on each host:"
    Write-Host "      • Database: http://10.0.0.196:8086 (InfluxDB)" -ForegroundColor Cyan
    Write-Host "      • Graylog: http://10.0.0.169:9000" -ForegroundColor Cyan
    Write-Host "      • Teleport: https://10.0.0.180:3080" -ForegroundColor Cyan
    Write-Host "      • Kubernetes: kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes" -ForegroundColor Cyan
    Write-Host "   3. Access Windows domain: RDP to 10.0.0.4 (DC-01)"
    Write-Host ""
    Write-Host "🔑 DEFAULT CREDENTIALS:" -ForegroundColor Yellow
    Write-Host "   • Linux SSH: Use your EC2 key pair"
    Write-Host "   • Windows RDP: Administrator / (check AMI password)"
    Write-Host "   • Graylog: admin / admin"
} else {
    Write-Host ""
    Write-Host "❌ Practice environment setup failed!" -ForegroundColor Red
    Write-Host "   Check the error messages above for details."
    Write-Host ""
    Write-Host "🔧 TROUBLESHOOTING TIPS:" -ForegroundColor Yellow
    Write-Host "   1. Ensure all EC2 instances are running and accessible"
    Write-Host "   2. Verify security groups allow SSH (port 22) from your IP"
    Write-Host "   3. Check that your SSH key is properly configured"
    Write-Host "   4. Manually test SSH connectivity: ssh -i your-key.pem ec2-user@10.0.0.X"
    exit 1
}