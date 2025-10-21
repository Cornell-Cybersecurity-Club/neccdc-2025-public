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

variable "windows_username" {
  type        = string
  description = "Username when authenticating to Windows, default is Administrator."
  default     = "Administrator"
}

variable "windows_password" {
  type        = string
  description = "Password for the Windows user."
  sensitive   = true
}

variable "volume_size" {
  type        = number
  description = "The size of the root volume in GB."
  default     = 50
}

variable "fast_launch" {
  type        = bool
  description = "Enable fast launch for the instance."
  default     = true
}

source "amazon-ebs" "firstrun-windows" {
  region        = var.aws_region
  ami_name      = "packer-windows-server-${local.timestamp}"
  source_ami    = "ami-021158f59b67638f2"
  instance_type = "t3a.2xlarge"
  security_group_id = var.security_group_id
  subnet_id         = var.subnet_id
  associate_public_ip_address = var.associate_public_ip
  profile       = var.aws_profile

  # EBS Storage Volume
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  # Fast launch settings
  fast_launch {
    enable_fast_launch = var.fast_launch
    
  }

  # Windows specific settings
  disable_stop_instance = true
  communicator          = "winrm"
  winrm_username        = var.windows_username
  winrm_password        = var.windows_password
  winrm_insecure        = true
  winrm_timeout         = "45m"
  winrm_use_ssl         = false

  user_data = templatefile("templates/bootstrap.pkrtpl.hcl", {
    windows_username = var.windows_username,
    windows_password = var.windows_password
  })

  tags = {
    "Name" = "packer-windows-server"
    "Date" = "${local.timestamp}"
  }
  run_tags = {
    "Name" = "packer-temporary-build-server"
  }
}