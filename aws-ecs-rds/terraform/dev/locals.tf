locals {
  env                = "dev"
  project            = "dev-training"
  azs_names          = toset(data.aws_availability_zones.available.names)
  domain             = "saito.page"
  domain_web         = "dev.${local.domain}"
  domain_api         = "dev-api.${local.domain}"
  domain_db_reader   = "db_reader.${local.domain}"
  domain_db_writer   = "db_writer.${local.domain}"
  bucket_name_prefix = "dev-training"
  log_group_bastion  = "/aws/ecs/bastion"
  # cloudfrontのマネージドキャッシュポリシー
  caching_disabled = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

  # alb
  api = {
    usage                      = "api"
    idle_timeout               = 60
    deregistration_delay       = 300
    enable_deletion_protection = false

    sg_port_rules_alb = [
      {
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 443
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  # ecs
  sg_port_rules_ecs = [
    {
      from_port   = 80
      to_port     = 80
      cidr_blocks = [module.vpc.vpc_cidr_block]
    },
    {
      from_port   = 1024
      to_port     = 65535
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  ]

  # iam user
  cloud_front = {
    user_name = "cloudfront-deploy"
  }
  app = {
    user_name = "app-deploy"
  }

  # rds
  db_port = 3306
  sg_port_rules_rds = [
    {
      from_port   = local.db_port
      to_port     = local.db_port
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  ]

  # waf
  body_size_constrains_byte = 10 * 1024 * 1024
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "main" {
  name = local.domain
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

