

resource "aws_route53_record" "cert_validation" {
  # name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  # type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  # zone_id = data.aws_route53_zone.main.id
  # records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  # ttl     = 60

   for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

data "aws_route53_zone" "main" {
  name         = var.hostname
  private_zone = false
}
