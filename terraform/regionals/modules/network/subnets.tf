resource "aws_subnet" "public" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = var.team_public_cidr_block

  tags = {
    Name    = "${var.team_number}-public"
    network = "public"
  }
}

resource "aws_subnet" "corp" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.cidr_block, 1, 0)

  tags = {
    Name    = "${var.team_number}-corp"
    network = "corp"
  }
}

resource "aws_subnet" "dmz" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.cidr_block, 3, 5)

  tags = {
    Name    = "${var.team_number}-dmz"
    network = "dmz"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.cidr_block, 2, 3)

  tags = {
    Name    = "${var.team_number}-private"
    network = "private"
  }
}
