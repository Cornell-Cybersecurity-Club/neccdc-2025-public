resource "aws_route53_record" "external" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.external_ip]
}

resource "aws_route53_record" "external_wildcard" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "*.${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.external_ip]
}

resource "aws_route53_record" "database" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "database.${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.database_ip]
}

resource "aws_route53_record" "palo_mgmt" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "firewall.${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.palo_mgmt_ip]
}
