# Aレコード作成するために既存のホストゾーンを参照
data "aws_route53_zone" "host_zone" {
  name = local.domain_name
}

resource "aws_route53_record" "static-www" {
  zone_id = data.aws_route53_zone.host_zone.id
  name    = local.site_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static-www.domain_name
    zone_id                = aws_cloudfront_distribution.static-www.hosted_zone_id
    evaluate_target_health = false
  }
}
