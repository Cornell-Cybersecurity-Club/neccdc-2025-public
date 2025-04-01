resource "aws_network_acl" "team" {
  vpc_id = var.team_vpc_id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.team_public_cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.black_team_vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 103
    action     = "allow"
    cidr_block = var.public_subnet_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 104
    action     = "deny"
    cidr_block = var.team_vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Black
  ingress {
    protocol   = "-1"
    rule_no    = 50
    action     = "allow"
    cidr_block = "192.168.215.0/24"
    from_port  = 0
    to_port    = 0
  }

  # Red
  ingress {
    protocol   = "-1"
    rule_no    = 51
    action     = "allow"
    cidr_block = "192.168.216.0/24"
    from_port  = 0
    to_port    = 0
  }

  # Blue
  ingress {
    protocol   = "-1"
    rule_no    = 52
    action     = "allow"
    cidr_block = "192.168.${var.team_number + 100}.0/24"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 999
    action     = "deny"
    cidr_block = var.rwu_ipsec_vpn_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Black
  egress {
    protocol   = "-1"
    rule_no    = 50
    action     = "allow"
    cidr_block = "192.168.215.0/24"
    from_port  = 0
    to_port    = 0
  }

  # Red
  egress {
    protocol   = "-1"
    rule_no    = 51
    action     = "allow"
    cidr_block = "192.168.216.0/24"
    from_port  = 0
    to_port    = 0
  }

  # Blue
  egress {
    protocol   = "-1"
    rule_no    = 52
    action     = "allow"
    cidr_block = "192.168.${var.team_number + 100}.0/24"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 99
    action     = "deny"
    cidr_block = var.rwu_ipsec_vpn_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.team_number}-nacl"
  }
}


resource "aws_network_acl_association" "public" {
  subnet_id      = aws_subnet.public.id
  network_acl_id = aws_network_acl.team.id
}

resource "aws_network_acl_association" "dmz" {
  subnet_id      = aws_subnet.dmz.id
  network_acl_id = aws_network_acl.team.id
}

resource "aws_network_acl_association" "private" {
  subnet_id      = aws_subnet.private.id
  network_acl_id = aws_network_acl.team.id
}

resource "aws_network_acl_association" "corp" {
  subnet_id      = aws_subnet.corp.id
  network_acl_id = aws_network_acl.team.id
}
