module "ses" {
  source = "../modules/ses"

  env         = local.env
  domain_name = local.domain
  zone_id     = data.aws_route53_zone.main.zone_id
  zone_name   = local.domain
}
