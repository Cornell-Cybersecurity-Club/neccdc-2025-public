data "aws_vpc" "black_team" {
  filter {
    name   = "tag:Name"
    values = ["black-team"]
  }
}

data "aws_vpc" "blue_team" {
  filter {
    name   = "tag:Name"
    values = ["team-mega-vpc"]
  }
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

data "aws_route_table" "management" {
  vpc_id = data.aws_vpc.blue_team.id

  filter {
    name   = "tag:team"
    values = ["shared"]
  }

  filter {
    name   = "tag:network"
    values = ["management"]
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
  name = "known-neccdc-hosts"
}
