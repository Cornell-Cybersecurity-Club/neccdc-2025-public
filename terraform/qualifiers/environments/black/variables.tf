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
