# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "black-team"
  cidr = "172.16.0.0/23"

  azs             = ["${var.region}a"]
  private_subnets = ["172.16.0.0/24"]
  public_subnets  = ["172.16.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  nat_gateway_tags = {
    Name = "black-team"
  }
}
