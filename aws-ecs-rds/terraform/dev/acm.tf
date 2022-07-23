module "acm_alb" {
  source = "../modules/acm"

  env                       = local.env
  domain_name               = "*.${local.domain}"
  subject_alternative_names = [local.domain]
  zone_id                   = data.aws_route53_zone.main.zone_id
}

module "acm_cloudfront" {
  source = "../modules/acm"

  env                       = local.env
  domain_name               = "*.${local.domain}"
  subject_alternative_names = [local.domain]
  zone_id                   = data.aws_route53_zone.main.zone_id

  providers = {
    aws = aws.cloud_front
  }
}
