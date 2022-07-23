locals {
  dafalut_tags = {
    env       = local.env
    project   = "training"
    terraform = "true"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = local.dafalut_tags
  }
}

provider "aws" {
  alias  = "cloud_front"
  region = "us-east-1"
  default_tags {
    tags = local.dafalut_tags
  }
}

terraform {
  required_version = ">= 1.1.6"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = [aws.cloud_front]
    }
  }
  backend "s3" {
    bucket  = "training-dev-tfstate"
    key     = "fargate-aurora/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
