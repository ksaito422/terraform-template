module "ecr_web" {
  source = "../modules/ecr"

  env           = local.env
  name          = "web"
  holding_count = 5
}

module "ecr_app" {
  source = "../modules/ecr"

  env           = local.env
  name          = "app"
  holding_count = 5
}

module "ecr_bastion" {
  source = "../modules/ecr"

  env           = local.env
  name          = "bastion"
  holding_count = 5
}
