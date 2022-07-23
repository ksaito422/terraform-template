variable "env" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "s3_bucket_domain_name" {
  type = string
}

variable "s3_bucket_id" {
  type = string
}

variable "price_class" {
  type    = string
  default = "PriceClass_All"
}

variable "acm_certificate_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "waf_web_acl_arn" {
  type = string
}

# stg = CachingDisabled, prod = CachingOptimizedのキャッシュポリシーを適用する
variable "cache_policy" {
  type = string
  validation {
    condition     = contains(["658327ea-f89d-4fab-a63d-7e88639e58f6", "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"], var.cache_policy)
    error_message = "ValidateException: bucket_type must be '658327ea-f89d-4fab-a63d-7e88639e58f6', '4135ea2d-6df8-44a3-9df3-4b5a84be39ad'."
  }
}

variable "cloudfront_functions" {
  type = string
}

variable "bucket_domain_name" {
  type = string
}

variable "log_prefix" {
  type = string
}
