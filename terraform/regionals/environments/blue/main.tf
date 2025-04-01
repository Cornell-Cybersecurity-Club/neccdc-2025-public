module "network" {
  source = "../../modules/network"

  team_number = terraform.workspace
  region      = var.region

  team_vpc_id   = data.aws_vpc.blue_team.id
  team_vpc_cidr = data.aws_vpc.blue_team.cidr_block

  black_team_vpc_cidr = data.aws_vpc.black_team.cidr_block

  rwu_ipsec_vpn_cidr = var.rwu_ipsec_vpn_cidr
  rwu_ipsec_vpg      = data.aws_vpn_gateway.site_to_site.id

  # CIDR 10.0.X.0/24 from team-mega-vpc
  cidr_block = cidrsubnet(data.aws_vpc.blue_team.cidr_block, 8, terraform.workspace)
  # CIDR 10.255.X.0/24 from team-mega-vpc
  team_public_cidr_block = cidrsubnet(data.aws_vpc.blue_team.cidr_block_associations[1].cidr_block, 8, terraform.workspace)

  # 10.255.255.0/24 - This covers the team-public subnet (NAT Gateway)
  public_subnet_cidr    = cidrsubnet(data.aws_vpc.blue_team.cidr_block_associations[1].cidr_block, 8, 255)
  public_route_table_id = data.aws_route_table.public.route_table_id

  vpc_peering_id         = data.aws_vpc_peering_connection.peer.id
  team_security_group_id = data.aws_security_group.team.id

  allowed_ips_prefix_list = data.aws_ec2_managed_prefix_list.known_hosts.id
}


module "route53" {
  source = "../../modules/route53"

  team_number = terraform.workspace
  external_ip = module.network.firewall_public_ip
}


module "instances" {
  source = "../../modules/instances"

  team_number = terraform.workspace

  subnet_corp_id      = module.network.subnet_corp_id
  subnet_corp_cidr    = module.network.subnet_corp_cidr
  subnet_dmz_id       = module.network.subnet_dmz_id
  subnet_dmz_cidr     = module.network.subnet_dmz_cidr
  subnet_private_id   = module.network.subnet_private_id
  subnet_private_cidr = module.network.subnet_private_cidr

  pfSense_instance_interfaces = module.network.pfSense_instance_interfaces

  key_pair          = "black-team"
  security_group_id = data.aws_security_group.team.id
}
