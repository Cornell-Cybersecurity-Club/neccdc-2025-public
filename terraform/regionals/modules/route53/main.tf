resource "aws_route53_record" "web" {
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

resource "aws_route53_record" "teleport_wildcard" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "*.teleport.${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.external_ip]
}
