resource "aws_subnet" "public" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = var.secondary_cidr_block

  tags = {
    Name    = "${var.team_number}-public"
    network = "public"
  }
}

resource "aws_subnet" "dmz" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.primary_cidr_block, 3, 1)

  tags = {
    Name    = "${var.team_number}-dmz"
    network = "dmz"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.primary_cidr_block, 1, 1)

  tags = {
    Name    = "${var.team_number}-private"
    network = "private"
  }
}

resource "aws_subnet" "management" {
  vpc_id                  = var.team_vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.primary_cidr_block, 4, 0)

  tags = {
    Name    = "${var.team_number}-management"
    network = "management"
  }
}
