resource "aws_security_group" "pfSense_public" {
  name        = "${var.team_number}-pfSense-Public"
  description = "Allow ingress to pfSense only from WireGuard, black team NAT Gateway and other IPs"
  vpc_id      = var.team_vpc_id

  ingress {
    description = "Allow all in from internal networks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      var.black_team_vpc_cidr,
      var.cidr_block,
      var.team_public_cidr_block
    ]
  }

  ingress {
    description     = "Allow all in from known hosts"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    prefix_list_ids = [var.allowed_ips_prefix_list]
  }

  egress {
    description      = "Allow all out"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.team_number}-pfSense-Public"
  }
}
