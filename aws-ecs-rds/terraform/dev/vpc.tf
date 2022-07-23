module "vpc" {
  source = "../modules/vpc"

  env             = local.env
  vpc_cidr        = "190.100.0.0/16"
  public_subnets  = ["190.100.1.0/24", "190.100.10.0/24", "190.100.20.0/24"]
  private_subnets = ["190.100.100.0/24", "190.100.110.0/24", "190.100.120.0/24"]
  azs             = local.azs_names
}
