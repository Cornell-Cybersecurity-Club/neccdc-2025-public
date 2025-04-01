variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region to deploy resources"
}

locals {
  secondary_cidr_block = [
    for assoc in data.aws_vpc.blue_team.cidr_block_associations : assoc.cidr_block
    if assoc.cidr_block != data.aws_vpc.blue_team.cidr_block
  ][0]
}
