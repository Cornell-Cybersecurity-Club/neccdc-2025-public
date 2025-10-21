# NECCDC 2025 - Shared Packer Variables
# This file contains common AWS configuration used by all AMI builds

# AWS Configuration
aws_region    = "us-east-2"
aws_profile   = "neccdc-2025"

# Network Configuration (Black Team VPC)
vpc_id            = "vpc-06e49e89be601f484"
subnet_id         = "subnet-0c392190026498665"
security_group_id = "sg-003fd7d2e39c5aca8"

# Common Instance Settings
associate_public_ip = true

# Common Tags
common_tags = {
  Project     = "NECCDC-2025"
  Environment = "competition"
  BuildDate   = "2025-10-19"
}