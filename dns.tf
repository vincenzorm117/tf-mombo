

data "aws_route53_zone" "main" {
  for_each     = local.domains
  name         = each.value
  private_zone = false
}



# resource "aws_route53_record" "mombo-cloudfront-route53" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = var.hostname
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.mombo-deploy.domain_name
#     zone_id                = aws_cloudfront_distribution.mombo-deploy.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
