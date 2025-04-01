resource "aws_vpc" "team_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "team-mega-vpc"
    team = "shared"
  }
}


resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.team_vpc.id
  cidr_block = "10.255.0.0/16"
}


resource "aws_internet_gateway" "team" {
  vpc_id = aws_vpc.team_vpc.id

  tags = {
    Name = "team-igw"
    team = "shared"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.team.id
  }

  route {
    cidr_block                = "172.16.0.0/22"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name    = "team-public"
    team    = "shared"
    network = "public"
  }
}

resource "aws_route_table" "management" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block                = "172.16.0.0/22"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name    = "team-management"
    team    = "shared"
    network = "management"
  }
}


resource "aws_security_group" "blue_team_ec2" {
  name        = "blue-team-ec2"
  description = "Allow access in and out for all blue team servers"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    description = "Allow all in"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "blue-team"
    team = "shared"
  }
}



resource "aws_default_route_table" "team" {
  default_route_table_id = aws_vpc.team_vpc.default_route_table_id

  tags = {
    Name = "team-default"
  }
}

resource "aws_default_network_acl" "team" {
  default_network_acl_id = aws_vpc.team_vpc.default_network_acl_id

  tags = {
    Name = "team-default"
  }
}

resource "aws_default_security_group" "team" {
  vpc_id = aws_vpc.team_vpc.id

  tags = {
    Name = "team-default"
  }
}
