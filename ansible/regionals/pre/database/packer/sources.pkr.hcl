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
  ami_name                    = "packer-database-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = var.associate_public_ip

  # https://aws.amazon.com/marketplace/pp/prodview-k66o7o642dfve
  # CentOS-Stream-ec2-9 (x86_64) for HVM Instances
  source_ami    = "ami-011d59a275b482a49"
  instance_type = "t3a.xlarge"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 24
    delete_on_termination = true
  }

  tags = {
    "Name" = "packer-database"
    "date" = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-database"
  }
}
