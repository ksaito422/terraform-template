# Terraformのバージョン固定
terraform {
  required_version = "= 1.1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# プロバイダーの設定
provider "aws" {
  profile = "terraformer"
  region  = "ap-northeast-1"
}

# ALB用
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
