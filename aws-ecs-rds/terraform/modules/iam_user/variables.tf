variable "env" {
  type = string
}

variable "user_name" {
  type = string
}

variable "policies" {
  type = list(
    object(
      {
        name      = string
        actions   = list(string)
        resources = list(string)
        condition = list(
          object(
            {
              test     = string
              variable = string
              values   = list(string)
            }
          )
        )
      }
    )
  )
  default = []
}
