variable "env" {
  type = string
}

variable "domain" {
  type    = string
  default = ""
}

variable "bucket_name" {
  type = string
}

variable "bucket_type" {
  type = string
  validation {
    condition     = contains(["web", "image", "log"], var.bucket_type)
    error_message = "ValidateException: bucket_type must be 'web', 'image', 'log'."
  }
}

variable "bucket_policies" {
  type = list(
    object(
      {
        principal_type       = string
        identifiers          = list(string)
        allow_resource_name  = string
        bucket_policy_action = list(string)
      }
    )
  )
  validation {
    condition = alltrue([
      for o in var.bucket_policies : contains(["AWS", "Service", "Federated"], o.principal_type)
    ])
    error_message = "ValidateException: bucket_type must be 'web', 'image', 'log'."
  }
}

