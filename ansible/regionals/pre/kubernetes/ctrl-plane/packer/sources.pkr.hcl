# Shared AWS variables
variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-2"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to use"
  default     = "neccdc-2025"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for instance"
  default     = "subnet-0c392190026498665"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for instance"
  default     = "sg-003fd7d2e39c5aca8"
}

variable "associate_public_ip" {
  type        = bool
  description = "Associate public IP address"
  default     = true
}

# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region                      = var.aws_region
  profile                     = var.aws_profile
  ami_name                    = "packer-kubernetes-ctrl-plane-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = var.associate_public_ip

  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240927
  # Canonical, Ubuntu, 24.04, amd64 noble image
  source_ami    = "ami-0ea3c35c5c3284d82"
  instance_type = "t3a.medium"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  tags = {
    "Name" = "packer-kubernetes-ctrl-plane"
    "date" = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-ctrl-plane"
  }
}
