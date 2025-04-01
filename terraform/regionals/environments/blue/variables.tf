variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region to deploy resources"
}

# I'm lazy and did not do a data call :)
variable "rwu_ipsec_vpn_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The RWU internal network cidr block"
}
