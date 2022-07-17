locals {
  project = "tf-template"
  env     = "dev"

  default_tags = {
    Project   = local.project
    Env       = local.env
    Terraform = true
  }
}
