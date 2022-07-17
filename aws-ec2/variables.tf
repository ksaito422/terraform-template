variable "aws_region" {
  type        = string
  description = "AWSのリージョン"
  default     = "ap-northeast-1"
}

variable "app_name" {
  type        = string
  description = "製品名"
  default     = "app"
}

variable "app_instance" {
  type        = string
  description = "インスタンスの名前"
  default     = "instance"
}

variable "app_stage" {
  type        = string
  description = "ステージ名称(dev, stg, prod)"
  default     = "dev"
}

variable "global_tags" {
  type = map(any)

  default = {
    Provisioner = "Terraform"
    Owner       = "あなたのお名前"
  }
}
