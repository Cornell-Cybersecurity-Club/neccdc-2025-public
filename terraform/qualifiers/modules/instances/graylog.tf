data "aws_ami" "debian" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "graylog" {
  ami           = data.aws_ami.debian.image_id
  instance_type = "t3a.large"
  key_name      = var.key_pair

  subnet_id  = var.subnet_dmz_id
  private_ip = cidrhost(var.subnet_dmz_cidr, 119)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  root_block_device {
    volume_size = 45
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.team_number}-graylog"
    service = "graylog"
  }
}
