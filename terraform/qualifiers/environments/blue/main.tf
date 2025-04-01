module "network" {
  source = "../../modules/network"

  team_number = terraform.workspace
  region      = var.region

  team_vpc_id   = data.aws_vpc.blue_team.id
  team_vpc_cidr = data.aws_vpc.blue_team.cidr_block

  black_team_vpc_cidr = data.aws_vpc.black_team.cidr_block

  # CIDR 10.0.X.0/22 from team-mega-vpc
  primary_cidr_block = cidrsubnet(data.aws_vpc.blue_team.cidr_block, 6, terraform.workspace)
  # CIDR 10.255.X.0/24 (private public)
  secondary_cidr_block = cidrsubnet(local.secondary_cidr_block, 8, terraform.workspace)
  # 10.255.255.0/24 - This covers the team-public subnet (NAT Gateway)
  public_subnet_cidr = cidrsubnet(local.secondary_cidr_block, 8, 255)

  public_route_table_id     = data.aws_route_table.public.route_table_id
  management_route_table_id = data.aws_route_table.management.route_table_id

  vpc_peering_id         = data.aws_vpc_peering_connection.peer.id
  team_security_group_id = data.aws_security_group.team.id

  allowed_ips_prefix_list = data.aws_ec2_managed_prefix_list.known_hosts.id
}


module "instances" {
  source = "../../modules/instances"

  team_number = terraform.workspace

  subnet_dmz_id       = module.network.subnet_dmz_id
  subnet_dmz_cidr     = module.network.subnet_dmz_cidr
  subnet_private_id   = module.network.subnet_private_id
  subnet_private_cidr = module.network.subnet_private_cidr

  key_pair          = "black-team"
  security_group_id = data.aws_security_group.team.id

  palo_instance_interfaces = module.network.palo_instance_interfaces
}


module "route53" {
  source = "../../modules/route53"

  team_number = terraform.workspace

  database_ip = module.instances.database_ip
  external_ip = module.network.firewall_public_ip
  palo_mgmt_ip = module.network.firewall_interface_ips.management
}
