locals { timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp()) }

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
  region        = "us-east-2"
  ami_name      = "packer-windows-workstation-${local.timestamp}"
  source_ami    = "ami-0b041308c8b9767f3"
  instance_type = "t3a.2xlarge"
  security_group_id = "sg-027af0024a1813997"
  subnet_id         = "subnet-04255ba24872d7d79"
  associate_public_ip_address = true

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
  winrm_timeout         = "15m"
  winrm_use_ssl         = false

  user_data = templatefile("${path.root}/templates/bootstrap.pkrtpl.hcl", {
    windows_username = var.windows_username,
    windows_password = var.windows_password
  })

  tags = {
    "Name" = "packer-windows-workstation"
    "Date" = "${local.timestamp}"
  }
  run_tags = {
    "Name" = "packer-temporary-build-server"
  }
}