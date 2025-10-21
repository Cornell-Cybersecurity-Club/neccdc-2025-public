# https://www.packer.io/plugins/builders/amazon/ebs

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

source "amazon-ebs" "vm" {
  region            = var.aws_region
  ami_name          = "packer-kubernetes-docker-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id

  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2024-09-27
  # No default gp3 image exists for ubuntu 22.04
  source_ami                  = "ami-00eb69d236edcfaf8"
  instance_type               = "t3a.medium"
  associate_public_ip_address = var.associate_public_ip

  profile = var.aws_profile

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_type           = "gp3"
    volume_size           = 32
    delete_on_termination = true
  }

  tags = {
    "Name" = "packer-kubernetes-docker"
    "date" = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-docker"
  }
}
