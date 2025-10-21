data "aws_ami" "teleport" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-teleport-*"]
  }

  owners = ["self"]
}


resource "aws_instance" "teleport" {
  ami           = data.aws_ami.teleport.image_id
  instance_type = "t4g.small"  # Optimized: was t4g.medium ($25/mo), now t4g.small ($13/mo)

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_dmz_id
  private_ip = cidrhost(var.subnet_dmz_cidr, 20)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-teleport"
    service = "teleport"
  }
}
