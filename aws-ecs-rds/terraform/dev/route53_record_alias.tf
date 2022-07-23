module "route53_record_alias_api" {
  source = "../modules/route53_record_alias"

  route53_zone_id        = data.aws_route53_zone.main.zone_id
  route53_name           = local.domain_api
  alias_name             = module.alb_api.dns_name
  alias_zone_id          = module.alb_api.zone_id
  evaluate_target_health = true
}

