resource "aws_subnet" "instance_connect" {
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]

  vpc_id                  = aws_vpc.team_vpc.id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  cidr_block              = "10.255.255.0/24"

  tags = {
    Name = "team-public"
    team = "shared"
  }
}

resource "aws_route_table" "instance_connect" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.team.id
  }

  tags = {
    Name    = "instance-connect"
    team    = "shared"
    network = "public"
  }
}


resource "aws_route_table_association" "instance_connect" {
  subnet_id      = aws_subnet.instance_connect.id
  route_table_id = aws_route_table.instance_connect.id
}


resource "aws_network_acl" "instance_connect" {
  vpc_id = aws_vpc.team_vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 1
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 1
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "public-nacl"
    team = "shared"
  }
}

resource "aws_network_acl_association" "main" {
  network_acl_id = aws_network_acl.instance_connect.id
  subnet_id      = aws_subnet.instance_connect.id
}

# https://aws.amazon.com/blogs/compute/secure-connectivity-from-public-to-private-introducing-ec2-instance-connect-endpoint-june-13-2023/
resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id = aws_subnet.instance_connect.id

  security_group_ids = [
    aws_security_group.instance_endpoint.id
  ]

  tags = {
    Name = "MegaVPC-ec2-instance-endpoint"
  }
}

resource "aws_security_group" "instance_endpoint" {
  name        = "ec2-instance-endpoint"
  description = "Allow all servers to connect to EC2 instance endpoint"
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
    Name = "ec2-instance-endpoint"
    team = "shared"
  }
}
