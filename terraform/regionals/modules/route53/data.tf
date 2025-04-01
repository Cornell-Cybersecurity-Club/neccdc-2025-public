data "aws_route53_zone" "public" {
  name         = "placebo-pharma.com."
  private_zone = false
}
