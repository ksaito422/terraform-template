module "alb_api" {
  source = "../modules/alb"

  env     = local.env
  project = local.project
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids

  usage                      = local.api.usage
  sg_port_rules              = local.api.sg_port_rules_alb
  idle_timeout               = local.api.idle_timeout
  deregistration_delay       = local.api.deregistration_delay
  enable_deletion_protection = local.api.enable_deletion_protection
  https_certificate_arn      = module.acm_alb.certificate_arn
  dependency                 = module.acm_alb.dependency
}

