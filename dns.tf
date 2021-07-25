

data "aws_route53_zone" "main" {
  for_each     = local.domains
  name         = each.value
  private_zone = false
}



resource "aws_route53_record" "cloudfront" {
  for_each = local.static_sites

  zone_id = data.aws_route53_zone.main[local.static_site_domains_to_root_domain[each.value.hostname]].zone_id
  name    = each.value.hostname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site[each.value.hostname].domain_name
    zone_id                = aws_cloudfront_distribution.site[each.value.hostname].hosted_zone_id
    evaluate_target_health = false
  }
}
