data "aws_iam_instance_profile" "session_manager" {
  name = "SessionManagerRole"
}

data "aws_ami" "windows_client" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-windows-workstation-*"]
  }
}

data "aws_ami" "windows_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-windows-server-*"]
  }
}
