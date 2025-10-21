resource "tls_private_key" "scorestack" {
  algorithm = "RSA"
}

resource "acme_registration" "scorestack" {
  account_key_pem = tls_private_key.scorestack.private_key_pem
  email_address   = "noreply@neccdl.org"
}

resource "acme_certificate" "scorestack" {
  account_key_pem = acme_registration.scorestack.account_key_pem
  common_name     = "*.placebo-pharma.com"

  subject_alternative_names = [
    "*.placebo-pharma.com"
  ]

  dns_challenge {
    provider = "route53"
    config = {
      AWS_REGION = "us-east-2"
    }
  }
}


resource "local_file" "scorestack_private_key_pem" {
  content  = acme_certificate.scorestack.private_key_pem
  filename = "../../../../documentation/black_team/certificates/scorestack/private.key"
}

resource "local_file" "scorestack_issuer" {
  content  = acme_certificate.scorestack.issuer_pem
  filename = "../../../../documentation/black_team/certificates/scorestack/cabundle.crt"
}

resource "local_file" "scorestack_cert" {
  content  = acme_certificate.scorestack.certificate_pem
  filename = "../../../../documentation/black_team/certificates/scorestack/cert.crt"
}

resource "local_file" "scorestack_fullchain" {
  content  = "${acme_certificate.scorestack.certificate_pem}${acme_certificate.scorestack.issuer_pem}"
  filename = "../../../../documentation/black_team/certificates/scorestack/fullchain.crt"
}
