resource "aws_instance" "win-01" {
  ami           = data.aws_ami.windows_client.image_id
  instance_type = "t3a.large"
  key_name      = var.key_pair

  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 128)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-windows-workstation"
    service = "windows-workstation"
  }
}
