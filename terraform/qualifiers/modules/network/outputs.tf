output "firewall_interface_ips" {
  value = {
    public     = tolist(aws_network_interface.public.private_ips)[0]
    dmz        = tolist(aws_network_interface.dmz.private_ips)[0]
    private    = tolist(aws_network_interface.private.private_ips)[0]
    management = tolist(aws_network_interface.management.private_ips)[0]
  }
  description = "The IPs of the firewalls interfaces"
}

output "firewall_public_ip" {
  value       = aws_eip.palo_public.public_ip
  description = "The public IP of the PaloAlto firewall"
}

output "subnet_public_id" {
  value       = aws_subnet.public.id
  description = "ID of the public subnet"
}

output "subnet_public_cidr" {
  value       = aws_subnet.public.cidr_block
  description = "CIDR block of the public subnet"
}

output "subnet_dmz_id" {
  value       = aws_subnet.dmz.id
  description = "ID of the dmz subnet"
}

output "subnet_dmz_cidr" {
  value       = aws_subnet.dmz.cidr_block
  description = "CIDR block of the dmz subnet"
}

output "subnet_private_id" {
  value       = aws_subnet.private.id
  description = "ID of the private subnet"
}

output "subnet_private_cidr" {
  value       = aws_subnet.private.cidr_block
  description = "CIDR block of the private subnet"
}

output "palo_management_eni_id" {
  value       = aws_network_interface.management.id
  description = "ID of the Palo Alto management network interface"
}

output "palo_public_eni_id" {
  value       = aws_network_interface.public.id
  description = "ID of the Palo Alto public network interface"
}

output "palo_private_eni_id" {
  value       = aws_network_interface.private.id
  description = "ID of the Palo Alto private network interface"
}

output "palo_dmz_eni_id" {
  value       = aws_network_interface.dmz.id
  description = "ID of the Palo Alto dmz network interface"
}

output "palo_instance_interfaces" {
  value = {
    management = aws_network_interface.management.id
    public     = aws_network_interface.public.id
    private    = aws_network_interface.private.id
    dmz        = aws_network_interface.dmz.id
  }
  description = "IDs of the Palo Alto network interfaces"
}
