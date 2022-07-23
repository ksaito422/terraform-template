variable "env" {
  type = string
}

variable "project" {
  type = string
}

# this param is use for name of resouces
variable "usage" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "sg_port_rules" {
  type = list(
    object(
      {
        from_port   = number
        to_port     = number
        cidr_blocks = list(string)
      }
    )
  )
}
variable "enable_deletion_protection" {
  default = true
}

variable "idle_timeout" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "https_certificate_arn" {
  type = string
}

variable "deregistration_delay" {
  type = number
}

# only aws_acm_certificate_validation
variable "dependency" {
  type = any
}
