# Terraformのバージョン固定
terraform {
  required_version = "~> 1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket  = "training-dev-tfstate"
    region  = "ap-northeast-1"
    profile = "terraformer"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  profile = "terraformer"
  region  = var.aws_region
  default_tags {
    tags = local.default_tags
  }
}

