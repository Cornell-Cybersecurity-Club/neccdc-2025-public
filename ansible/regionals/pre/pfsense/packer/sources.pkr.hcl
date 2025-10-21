locals { timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp()) }

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile"
  default     = "neccdc-2025"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  default     = "subnet-0c392190026498665"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID"
  default     = "sg-003fd7d2e39c5aca8"
}

variable "associate_public_ip" {
  type        = bool
  description = "Associate public IP"
  default     = true
}

variable "pfsense_username" {
  type        = string
  description = "Username when authenticating to pfsense, default is admin."
  default     = "admin"
}

variable "pfsense_password" {
  type        = string
  description = "Password for the pfsense user."
  sensitive   = true
}

variable "pfsense_version" {
  type        = string
  description = "pfSense version to use"
  default     = "25.07.1"

  validation {
    condition     = contains(["25.07", "25.07.1"], var.pfsense_version)
    error_message = "Invalid pfSense version must be 25.07 or 25.07.1."
  }
}

source "amazon-ebs" "vm" {
  region                      = var.aws_region
  ami_name                    = "packer-pfsense-${var.pfsense_version}-${local.timestamp}"
  instance_type               = "c5.xlarge"
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = var.associate_public_ip
  profile                     = var.aws_profile

  source_ami_filter {
    most_recent = true
    owners      = ["aws-marketplace"]
    
    filters = {
       name = "pfSense-plus-ec2-${var.pfsense_version}-RELEASE-amd64*"
    }
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 32
    delete_on_termination = true
  }

  user_data = "password=${var.pfsense_password}"

  communicator         = "ssh"
  ssh_username         = "${var.pfsense_username}"
  ssh_password         = "${var.pfsense_password}"
  ssh_timeout          = "15m"
  ssh_handshake_attempts = 10
  ssh_pty              = true
  
  ssh_keypair_name     = "black-team"
  ssh_private_key_file = "../../../../../documentation/black_team/black-team"

  tags = {
    "Name" = "packer-pfsense-${var.pfsense_version}"
    "date" = "${local.timestamp}"
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-pfsense"
  }
}
