variable "team_number" {
  type        = number
  description = "Team number"
}

variable "subnet_corp_id" {
  type        = string
  description = "The AWS Subnet ID for the Corp"
}

variable "subnet_corp_cidr" {
  type        = string
  description = "CIDR range of the Corp subnet"
}

variable "subnet_dmz_id" {
  type        = string
  description = "The AWS Subnet ID for the DMZ"
}

variable "subnet_dmz_cidr" {
  type        = string
  description = "CIDR range of the dmz subnet"
}

variable "subnet_private_id" {
  type        = string
  description = "The AWS Subnet ID for the private subnet"
}

variable "subnet_private_cidr" {
  type        = string
  description = "CIDR range of the private subnet"
}

variable "key_pair" {
  type        = string
  default     = "black-team"
  description = "Key pair to use for all instances"
}

variable "security_group_id" {
  type        = string
  description = "ID of the instances shared security group"
}

variable "pfSense_instance_interfaces" {
  description = "Map of Palo Alto network interface IDs"
  type = object({
    corp    = string
    dmz     = string
    private = string
    public  = string
  })
}
