data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-nginx-*"]
  }
}


resource "aws_instance" "nginx" {
  ami           = data.aws_ami.nginx.image_id
  instance_type = "t4g.small"
  key_name      = var.key_pair

  subnet_id  = var.subnet_dmz_id
  private_ip = cidrhost(var.subnet_dmz_cidr, 72)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-nginx"
    service = "nginx"
  }
}
