variable "env" {
  type = string
}

variable "usage" {
  type = string
  validation {
    condition     = contains(["api", "cms", "web"], var.usage)
    error_message = "ValidationException: usage must be 'api', 'cms', 'web'."
  }
}

variable "waf_scope" {
  type = string
  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.waf_scope)
    error_message = "ValidationException: waf_scope must be 'CLOUDFRONT', 'REGIONAL'."
  }
}

variable "resource_arn" {
  type    = string
  default = ""
}

variable "body_size_constrains" {
  type = number
  # AWSManagedRulesCommonRuleSetのSizeRestrictions_BODYはデフォルトで10240byte
  default = 10 * 1024
  validation {
    condition     = contains([10240, 10485760], var.body_size_constrains)
    error_message = "ValidationException: body_size_constrains must be '10240', '10485760'."
  }
}

variable "cloudwatch_log_group_arn" {
  type = string
}

