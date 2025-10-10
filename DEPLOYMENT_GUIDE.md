# NECCDC 2025 - Quick Start Deployment Guide

This guide will help you deploy the CCDC infrastructure to AWS in minutes.

## Prerequisites

- AWS Account with billing enabled
- Administrator/sudo access on your computer
- ~$5-10/month for black team infrastructure (free tier eligible instances)

## Quick Start (Automated Setup)

### Windows (PowerShell as Administrator)

```powershell
# Clone the repository
git clone https://github.com/YOUR-USERNAME/neccdc-2025-public.git
cd neccdc-2025-public

# Run the automated setup script
.\setup.ps1
```

### Linux/macOS

```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/neccdc-2025-public.git
cd neccdc-2025-public

# Make setup script executable and run it
chmod +x setup.sh
./setup.sh
```

The setup script will automatically install:
- ✅ Git
- ✅ AWS CLI
- ✅ Terraform
- ✅ AWS Session Manager Plugin
- ✅ Python 3
- ✅ Ansible
- ✅ OpenSSH

## Step-by-Step Deployment

### 1. Configure AWS Credentials

```bash
aws configure --profile neccdc-2025
```

You'll need:
- **AWS Access Key ID**: Get from AWS IAM Console
- **AWS Secret Access Key**: Get from AWS IAM Console
- **Default region**: `us-east-2`
- **Default output format**: `json`

### 2. Create S3 Bucket for Terraform State

```bash
# Replace YOUR-BUCKET-NAME with something unique
aws s3 mb s3://YOUR-BUCKET-NAME --profile neccdc-2025 --region us-east-2

# Enable versioning (recommended)
aws s3api put-bucket-versioning \
  --bucket YOUR-BUCKET-NAME \
  --versioning-configuration Status=Enabled \
  --profile neccdc-2025 \
  --region us-east-2
```

### 3. Update Terraform Configuration

Edit `terraform/regionals/environments/black/settings.tf` and `terraform/regionals/environments/blue/settings.tf`:

```hcl
backend "s3" {
  bucket  = "YOUR-BUCKET-NAME"  # <-- Change this
  key     = "neccdc-2025/black/terraform.tfstate"
  region  = "us-east-2"
  profile = "neccdc-2025"
}
```

### 4. Configure Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit .env and fill in your values
# Windows: notepad .env
# Linux/Mac: nano .env
```

Required values in `.env`:
```bash
WIREGUARD_PASSWORD=YourSecurePasswordHere
WIREGUARD_PUBLIC_IP=  # Leave blank for now, fill in after deployment
```

### 5. Generate SSH Keypair

```bash
# Windows (PowerShell)
ssh-keygen -t rsa -b 4096 -f documentation/black_team/black-team -N '""'

# Linux/Mac
ssh-keygen -t rsa -b 4096 -f documentation/black_team/black-team -N ''
```

This creates:
- `documentation/black_team/black-team` (private key - **NEVER commit to git**)
- `documentation/black_team/black-team.pub` (public key)

### 6. Deploy Black Team Infrastructure

```bash
cd terraform/regionals/environments/black

# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Deploy (this takes ~3-5 minutes)
terraform apply
```

Type `yes` when prompted. Terraform will create:
- 🌐 VPCs and networking
- 🔒 Security groups
- 🖥️ EC2 instances (Wireguard, Scorestack)
- 📡 Route53 private DNS zone
- 🔑 IAM roles and policies

### 7. Get Wireguard Public IP

After deployment completes, get the Wireguard server IP:

```bash
# Get the public IP
terraform output wireguard_public_ip

# Example output: 3.136.168.73
```

Update your `.env` file with this IP:
```bash
WIREGUARD_PUBLIC_IP=3.136.168.73
```

### 8. Setup Wireguard VPN

Connect to the Wireguard server using AWS Session Manager:

```bash
# Get the instance ID
terraform output wireguard_instance_id

# Connect (replace i-XXXXX with your instance ID)
aws ssm start-session \
  --target i-016a694ee05a56bc8 \
  --document-name "SSM-SessionManagerRunShell-Bash" \
  --profile neccdc-2025 \
  --region us-east-2
```

Once connected, run the Wireguard setup script:

```bash
# On the remote server
cd /tmp
cat > .env << 'EOF'
WIREGUARD_PASSWORD=YourSecurePasswordHere
WIREGUARD_PUBLIC_IP=3.136.168.73
EOF

# Download and run the setup script
curl -o setup-wireguard.sh https://raw.githubusercontent.com/YOUR-USERNAME/neccdc-2025-public/main/setup-wireguard.sh
chmod +x setup-wireguard.sh
./setup-wireguard.sh
```

### 9. Access Wireguard Web UI

Open your browser and navigate to:
```
http://YOUR-WIREGUARD-PUBLIC-IP:51821
```

Login with the password you set in `.env`.

### 10. Create VPN Client Configurations

In the Wireguard web UI:
1. Click **"+ New"** to create a new client
2. Enter a name (e.g., "laptop", "desktop")
3. Download the configuration file or scan the QR code
4. Import into your Wireguard client

Download Wireguard clients:
- **Windows/Mac/Linux**: https://www.wireguard.com/install/
- **iOS/Android**: Search "Wireguard" in App Store/Play Store

### 11. Connect and Access Infrastructure

Once connected to the VPN:

```bash
# SSH to instances via private DNS
ssh -i documentation/black_team/black-team ubuntu@scorestack.ccdc-test.internal

# Or use private IPs
ssh -i documentation/black_team/black-team ubuntu@172.16.1.200  # Scorestack
```

Access the Scorestack web UI (once configured):
```
http://scorestack.ccdc-test.internal
```

## Deployed Infrastructure

### Black Team VPC (172.16.0.0/23)

| Service | Private IP | DNS Name | Purpose |
|---------|-----------|----------|---------|
| Wireguard | 172.16.1.10 | wireguard.ccdc-test.internal | VPN Server |
| Scorestack | 172.16.1.200 | scorestack.ccdc-test.internal | Competition Scoring |

### Blue Team VPC (10.0.0.0/16)

Blue team infrastructure requires building custom AMIs (see Advanced Setup below).

## Accessing Deployed Infrastructure

### Method 1: AWS Session Manager (Recommended)

No SSH key required, works from any internet connection:

```bash
# List all running instances
aws ec2 describe-instances \
  --profile neccdc-2025 \
  --region us-east-2 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],PrivateIpAddress]' \
  --output table

# Connect to any instance
aws ssm start-session \
  --target INSTANCE-ID \
  --document-name "SSM-SessionManagerRunShell-Bash" \
  --profile neccdc-2025 \
  --region us-east-2
```

### Method 2: SSH via Wireguard VPN

Once connected to VPN:

```bash
ssh -i documentation/black_team/black-team ubuntu@PRIVATE-IP
```

### Method 3: SSH via Bastion Host

Use Wireguard as a jump host:

```bash
ssh -J ubuntu@WIREGUARD-PUBLIC-IP -i documentation/black_team/black-team ubuntu@PRIVATE-IP
```

## Costs

### Black Team Infrastructure
- **t3.micro instances**: Free tier eligible (750 hours/month)
- **EBS storage**: ~$2-3/month
- **Data transfer**: ~$1-2/month
- **Estimated total**: $3-5/month (or $0 if within free tier)

### Blue Team Infrastructure
- **Custom AMI storage**: ~$10-15/month
- **Running instances**: $20-40/month (if using 10+ instances)
- **Recommended**: Only deploy blue team when actively training

## Security Notes

⚠️ **Important**: Never commit these files to a public repository:
- `.env` (contains passwords)
- `documentation/black_team/black-team` (private SSH key)
- `terraform.tfstate` (contains sensitive data)
- Any file with real credentials

✅ These are already in `.gitignore` to protect you.

## Troubleshooting

### Cannot connect to Wireguard web UI
- Check security group allows TCP 51821: `terraform output wireguard_security_group_id`
- Verify Docker container is running: `sudo docker ps`
- Check logs: `sudo docker logs wireguard-black-team`

### SSH connection refused
- Use AWS Session Manager instead (more reliable)
- Verify security group allows your IP for SSH (port 22)
- Check instance is running: `aws ec2 describe-instances --instance-ids i-XXXXX`

### Terraform state locked
- Someone else might be running terraform
- Force unlock: `terraform force-unlock LOCK-ID`

### "Insufficient capacity" error during terraform apply
- Change instance type in terraform config
- Try a different availability zone
- Wait and try again later

## Cleanup (Destroy Infrastructure)

⚠️ This will delete everything and cannot be undone!

```bash
cd terraform/regionals/environments/black
terraform destroy
```

## Advanced Setup

### Building Blue Team AMIs

Blue team requires custom AMIs (4-8 hours to build, ~$20-40 in temporary compute costs):

```bash
# See documentation/AMI_BUILDING.md for detailed instructions
cd terraform/regionals/environments/blue
terraform apply
```

### Configuring Scorestack

```bash
cd scorestack
ansible-playbook -i ../terraform/regionals/environments/black/inventory.yaml playbook.yaml
```

## Support & Resources

- **Original Repository**: https://github.com/Cornell-Cybersecurity-Club/neccdc-2025-public
- **Wireguard Documentation**: https://www.wireguard.com/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **AWS Session Manager**: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

See LICENSE file for details.

---

**Happy hacking! 🎯🔒**
