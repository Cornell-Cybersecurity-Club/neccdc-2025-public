variable "team_number" {
  type        = string
  description = "The ID of the team"
}

variable "database_ip" {
  type        = string
  description = "The IP address of the database instance"
}

variable "external_ip" {
  type        = string
  description = "The IP address of probably the firewall"
}

variable "palo_mgmt_ip" {
  type        = string
  description = "The IP address of the Palo Alto management interface"
}