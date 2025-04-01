variable "allowed_ips_prefix_list" {
  type        = string
  description = "Prefix list containing known allowed IPs"
}

variable "black_team_vpc_cidr" {
  type        = string
  description = "CIDR block used by the Black team VPC"
}

variable "management_route_table_id" {
  type        = string
  description = "The route table id for the shared management subnet"
}

variable "primary_cidr_block" {
  type        = string
  description = "The primary cidr range for the team"
}

variable "public_route_table_id" {
  type        = string
  description = "The route table id for the public private subnet"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block of the public public subnet"
}

variable "region" {
  type        = string
  description = "The region to deploy the network in"
}

variable "secondary_cidr_block" {
  type        = string
  description = "The secondary cidr range for the team"
}

variable "team_security_group_id" {
  type        = string
  description = "The security group id for the team"
}

variable "team_number" {
  type        = number
  description = "Team number"
}

variable "team_vpc_cidr" {
  type        = string
  description = "The CIDR block for the team VPC"
}

variable "team_vpc_id" {
  type        = string
  description = "Team VPC id"
}

variable "vpc_peering_id" {
  type        = string
  description = "ID of the black to blue VPC peer"
}
