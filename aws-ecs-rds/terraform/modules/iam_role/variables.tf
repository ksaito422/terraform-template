variable "env" {
  type = string
}

variable "role_name" {
  type = string
}

variable "identifiers" {
  type = list(string)
}

variable "policies" {
  type = list(
    object(
      {
        name      = string
        actions   = list(string)
        resources = list(string)
      }
    )
  )
  default = []
}

variable "condition" {
  type = list(
    object(
      {
        test     = string
        variable = string
        values   = list(string)
      }
    )
  )
  default = []
}

variable "managed_policy_arn" {
  type    = list(string)
  default = []
}

