module "ecs" {
  source        = "../modules/ecs"
  env           = local.env
  project       = local.project
  vpc_id        = module.vpc.vpc_id
  sg_port_rules = local.sg_port_rules_ecs

  depends_on = [
    module.firehose_log_stream_ecs,
    module.ecr_bastion
  ]
}
