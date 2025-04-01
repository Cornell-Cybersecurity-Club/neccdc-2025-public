resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.rwu_ipsec_vpn_ip
  type       = "ipsec.1"

  tags = {
    Name = "rwu-customer-gateway"
  }
}

resource "aws_vpn_gateway" "this" {
  vpc_id = aws_vpc.team_vpc.id

  tags = {
    Name = "rwu-ipsec-vpn"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "rwu-ipsec-vpn"
  }
}

resource "aws_vpn_connection_route" "rwu" {
  destination_cidr_block = var.rwu_ipsec_vpn_cidr
  vpn_connection_id      = aws_vpn_connection.main.id
}
