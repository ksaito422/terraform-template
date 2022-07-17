locals {
  project     = "tf-template"
  env         = "dev"
  domain_name = "saito.page"
  site_domain = "test.saito.page"

  default_tags = {
    Project   = local.project
    Env       = local.env
    Terraform = true
  }
}
