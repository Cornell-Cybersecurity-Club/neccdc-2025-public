resource "aws_network_interface" "management" {
  subnet_id         = aws_subnet.management.id
  description       = "Management interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(cidrsubnet(var.primary_cidr_block, 3, 0), 10)] # 10.0.(X+2).10

  security_groups = [var.team_security_group_id]

  tags = {
    Name = "${var.team_number}-PaloAlto-Management"
  }
}


resource "aws_network_interface" "public" {
  subnet_id         = aws_subnet.public.id
  description       = "Public interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(var.secondary_cidr_block, -2)]

  security_groups = [aws_security_group.palo_public.id]

  tags = {
    Name = "${var.team_number}-PaloAlto-Public"
  }
}

resource "aws_eip" "palo_public" {
  domain            = "vpc"
  network_interface = aws_network_interface.public.id

  tags = {
    Name = "${var.team_number}-PaloAlto-Public-EIP"
  }
}


resource "aws_network_interface" "dmz" {
  subnet_id         = aws_subnet.dmz.id
  description       = "DMZ interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(cidrsubnet(var.primary_cidr_block, 3, 1), -2)]

  security_groups = [var.team_security_group_id]

  tags = {
    Name = "${var.team_number}-PaloAlto-DMZ"
  }
}


resource "aws_network_interface" "private" {
  subnet_id         = aws_subnet.private.id
  description       = "Private interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(cidrsubnet(var.primary_cidr_block, 1, 1), -2)]

  security_groups = [var.team_security_group_id]

  tags = {
    Name = "${var.team_number}-PaloAlto-Private"
  }
}
