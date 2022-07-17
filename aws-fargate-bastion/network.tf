module "network" {
  source = "./modules/network"

  prefix             = local.project
  project            = local.project
  vpc_cidr           = local.vpc_cidr
  private_subnets    = local.private_subnets
  db_subnets         = local.db_subnets
  interface_services = local.vpc_endpoint.interface
  gateway_services   = local.vpc_endpoint.gateway
}
