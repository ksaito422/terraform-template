################################################################################
# Route53 record
################################################################################

resource "aws_route53_record" "main" {
  zone_id = var.route53_zone_id
  name    = var.route53_name
  type    = var.type
  ttl     = var.ttl
  records = var.records
}
