resource "aws_network_interface" "public" {
  subnet_id         = aws_subnet.public.id
  description       = "Public interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(var.team_public_cidr_block, -2)]

  security_groups = [aws_security_group.pfSense_public.id]

  tags = {
    Name = "${var.team_number}-pfSense-public"
  }
}

resource "aws_eip" "pfSense_public" {
  domain            = "vpc"
  network_interface = aws_network_interface.public.id

  tags = {
    Name = "${var.team_number}-pfSense-public"
  }
}

resource "aws_network_interface" "corp" {
  subnet_id         = aws_subnet.corp.id
  description       = "Corp interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(cidrsubnet(var.cidr_block, 1, 0), -2)] # 10.0.X.126

  security_groups = [var.team_security_group_id]

  tags = {
    Name = "${var.team_number}-pfSense-corp"
  }
}


resource "aws_network_interface" "dmz" {
  subnet_id         = aws_subnet.dmz.id
  description       = "DMZ interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(cidrsubnet(var.cidr_block, 3, 5), -2)] # 10.0.X.190

  security_groups = [var.team_security_group_id]

  tags = {
    Name = "${var.team_number}-pfSense-dmz"
  }
}


resource "aws_network_interface" "private" {
  subnet_id         = aws_subnet.private.id
  description       = "Private interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(cidrsubnet(var.cidr_block, 2, 3), -2)] # 10.0.X.254

  security_groups = [var.team_security_group_id]

  tags = {
    Name = "${var.team_number}-pfSense-private"
  }
}
