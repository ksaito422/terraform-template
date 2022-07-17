data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "ecs" {
  source = "./modules/ecs"

  project      = local.project
  prefix       = local.project
  region       = data.aws_region.current.name
  ecr_base_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  vpc_id       = module.network.vpc_id
  subnet       = module.network.private_subnet_ids
}
