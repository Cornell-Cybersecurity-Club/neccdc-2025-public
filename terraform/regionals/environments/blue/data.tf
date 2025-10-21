data "aws_vpc" "black_team" {
  id = "vpc-06e49e89be601f484"
}

data "aws_vpc" "blue_team" {
  id = "vpc-0da4d03d7b738bbac"
}

data "aws_vpc_peering_connection" "peer" {
  vpc_id      = data.aws_vpc.blue_team.id
  peer_vpc_id = data.aws_vpc.black_team.id
}

data "aws_route_table" "public" {
  vpc_id = data.aws_vpc.blue_team.id

  filter {
    name   = "tag:Name"
    values = ["team-public"]
  }

  filter {
    name   = "tag:team"
    values = ["shared"]
  }

  filter {
    name   = "tag:network"
    values = ["public"]
  }
}

data "aws_security_group" "team" {
  vpc_id = data.aws_vpc.blue_team.id

  name = "blue-team-ec2"

  filter {
    name   = "tag:team"
    values = ["shared"]
  }
}

data "aws_ec2_managed_prefix_list" "known_hosts" {
  id = "pl-01259d217c52bcd28"
}

data "aws_vpn_gateway" "site_to_site" {
  attached_vpc_id = data.aws_vpc.blue_team.id

  filter {
    name   = "tag:Name"
    values = ["rwu-ipsec-vpn"]
  }
}
