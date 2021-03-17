
resource "aws_acm_certificate" "cert" {
  domain_name       = var.hostname
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
  # validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}