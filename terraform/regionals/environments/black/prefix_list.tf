resource "aws_ec2_managed_prefix_list" "known_hosts" {
  name           = "known-neccdc-hosts"
  address_family = "IPv4"
  max_entries    = 50

  entry {
    cidr        = "${module.vpc.nat_public_ips[0]}/32"
    description = "Black Team NAT"
  }

  entry {
    cidr        = "${aws_eip.scorestack.public_ip}/32"
    description = "Scorestack"
  }

  dynamic "entry" {
    for_each = var.allowed_ips
    content {
      cidr        = entry.value
      description = "Additional IP ${entry.key + 1}"
    }
  }

  tags = {
    Name = "known-neccdc-hosts"
    team = "shared"
  }
}
