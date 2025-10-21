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
  ami_name                    = "packer-teleport-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  # https://aws.amazon.com/marketplace/pp/prodview-6ihwigagrts66
  # Rocky-9-EC2-Base-9.4-20240523.0.aarch64-0d51926d-1cd1-4223-bda9-346993accc16
  source_ami                  = "ami-047e0292bc00ae1de"
  instance_type               = "t4g.large"
  associate_public_ip_address = var.associate_public_ip

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 13
    delete_on_termination = true
  }

  tags = {
    Name = "packer-teleport"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-tmp-build-server-teleport"
  }
}
