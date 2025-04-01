output "firewall_interface_ips" {
  value = {
    corp    = tolist(aws_network_interface.corp.private_ips)[0]
    dmz     = tolist(aws_network_interface.dmz.private_ips)[0]
    private = tolist(aws_network_interface.private.private_ips)[0]
    public  = tolist(aws_network_interface.public.private_ips)[0]
  }
  description = "The IPs of the firewalls interfaces"
}

output "firewall_public_ip" {
  value       = aws_eip.pfSense_public.public_ip
  description = "The public IP of the pfSenseAlto firewall"
}

output "subnet_public_id" {
  value       = aws_subnet.public.id
  description = "ID of the public subnet"
}

output "subnet_public_cidr" {
  value       = aws_subnet.public.cidr_block
  description = "CIDR block of the public subnet"
}


output "subnet_corp_id" {
  value       = aws_subnet.corp.id
  description = "ID of the corp subnet"
}

output "subnet_corp_cidr" {
  value       = aws_subnet.corp.cidr_block
  description = "CIDR block of the corp subnet"
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

output "pfSense_corp_eni_id" {
  value       = aws_network_interface.corp.id
  description = "ID of the pfSense Alto corp network interface"
}

output "pfSense_public_eni_id" {
  value       = aws_network_interface.public.id
  description = "ID of the pfSense Alto public network interface"
}

output "pfSense_private_eni_id" {
  value       = aws_network_interface.private.id
  description = "ID of the pfSense Alto private network interface"
}

output "pfSense_dmz_eni_id" {
  value       = aws_network_interface.dmz.id
  description = "ID of the pfSense Alto dmz network interface"
}

output "pfSense_instance_interfaces" {
  value = {
    corp    = aws_network_interface.corp.id
    private = aws_network_interface.private.id
    dmz     = aws_network_interface.dmz.id
    public  = aws_network_interface.public.id
  }

  description = "IDs of the pfSense Alto network interfaces"
}