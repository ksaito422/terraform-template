module "ecr" {
  source = "./modules/ecr"

  prefix = local.project
}
