resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = var.public_route_table_id
}


resource "aws_route_table" "corp" {
  vpc_id = var.team_vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.corp.id
  }

  route {
    cidr_block           = aws_subnet.dmz.cidr_block
    network_interface_id = aws_network_interface.corp.id
  }

  route {
    cidr_block           = aws_subnet.corp.cidr_block
    network_interface_id = aws_network_interface.corp.id
  }

  route {
    cidr_block           = aws_subnet.private.cidr_block
    network_interface_id = aws_network_interface.corp.id
  }

  route {
    cidr_block           = aws_subnet.public.cidr_block
    network_interface_id = aws_network_interface.corp.id
  }

  route {
    cidr_block                = var.black_team_vpc_cidr
    vpc_peering_connection_id = var.vpc_peering_id
  }

  route {
    cidr_block = var.rwu_ipsec_vpn_cidr
    gateway_id = var.rwu_ipsec_vpg
  }

  tags = {
    Name    = "${var.team_number}-corp"
    network = "corp"
  }
}

resource "aws_route_table_association" "corp" {
  subnet_id      = aws_subnet.corp.id
  route_table_id = aws_route_table.corp.id
}



resource "aws_route_table" "dmz" {
  vpc_id = var.team_vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.dmz.id
  }

  route {
    cidr_block           = aws_subnet.dmz.cidr_block
    network_interface_id = aws_network_interface.dmz.id
  }

  route {
    cidr_block           = aws_subnet.corp.cidr_block
    network_interface_id = aws_network_interface.dmz.id
  }

  route {
    cidr_block           = aws_subnet.private.cidr_block
    network_interface_id = aws_network_interface.dmz.id
  }

  route {
    cidr_block           = aws_subnet.public.cidr_block
    network_interface_id = aws_network_interface.dmz.id
  }

  route {
    cidr_block                = var.black_team_vpc_cidr
    vpc_peering_connection_id = var.vpc_peering_id
  }

  route {
    cidr_block = var.rwu_ipsec_vpn_cidr
    gateway_id = var.rwu_ipsec_vpg
  }

  tags = {
    Name    = "${var.team_number}-dmz"
    network = "dmz"
  }
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = aws_subnet.dmz.id
  route_table_id = aws_route_table.dmz.id
}


resource "aws_route_table" "private" {
  vpc_id = var.team_vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.dmz.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.corp.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.private.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.public.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block                = var.black_team_vpc_cidr
    vpc_peering_connection_id = var.vpc_peering_id
  }

  route {
    cidr_block = var.rwu_ipsec_vpn_cidr
    gateway_id = var.rwu_ipsec_vpg
  }

  tags = {
    Name    = "${var.team_number}-private"
    network = "private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
