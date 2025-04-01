variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region to deploy resources"
}

variable "allowed_ips" {
  type = list(string)
  default = [
    "10.11.12.13/32"
  ]
  description = "Additional allowed IPs"
}

variable "rwu_ipsec_vpn_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The RWU internal network cidr block"
}

variable "rwu_ipsec_vpn_ip" {
  type        = string
  default     = "1.1.1.1"
  description = "The pubic IP address of the RWU IPSec VPN endpoint"
}

variable "validation" {
  type        = bool
  description = "Make sure this change does not impact the RWU IPSEC VPN?"
}
