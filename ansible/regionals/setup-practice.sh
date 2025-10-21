#!/bin/bash

# NECCDC 2025 Practice Environment Setup
# This script sets up a single blue team practice environment

set -e  # Exit on any error

echo "🏁 NECCDC 2025 Practice Environment Setup"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "practice-setup.py" ]; then
    echo "❌ Error: practice-setup.py not found. Please run this script from the ansible/regionals directory."
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not installed."
    exit 1
fi

# Check if Ansible is available  
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Error: Ansible is required but not installed."
    echo "   Install with: pip install ansible"
    exit 1
fi

# Check if we have the inventory directory
if [ ! -d "inventory" ]; then
    echo "❌ Error: inventory directory not found."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Run the Python setup script
echo "🚀 Running practice environment setup..."
python3 practice-setup.py

# Check the exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Practice environment setup completed successfully!"
    echo ""
    echo "📋 NEXT STEPS:"
    echo "   1. Verify all EC2 instances are accessible"
    echo "   2. Test services on each host:"
    echo "      • Database: http://10.0.0.196:8086 (InfluxDB)"
    echo "      • Graylog: http://10.0.0.169:9000"
    echo "      • Teleport: https://10.0.0.180:3080" 
    echo "      • Kubernetes: kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes"
    echo "   3. Access Windows domain: RDP to 10.0.0.4 (DC-01)"
    echo ""
    echo "🔑 DEFAULT CREDENTIALS:"
    echo "   • Linux SSH: Use your EC2 key pair"
    echo "   • Windows RDP: Administrator / (check AMI password)"
    echo "   • Graylog: admin / admin"
else
    echo ""
    echo "❌ Practice environment setup failed!"
    echo "   Check the error messages above for details."
    echo ""
    echo "🔧 TROUBLESHOOTING TIPS:"
    echo "   1. Ensure all EC2 instances are running and accessible"
    echo "   2. Verify security groups allow SSH (port 22) from your IP"
    echo "   3. Check that your SSH key is properly configured"
    echo "   4. Manually test SSH connectivity: ssh -i your-key.pem ec2-user@10.0.0.X"
    exit 1
fi