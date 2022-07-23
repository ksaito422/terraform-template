variable "env" {
  type = string
}

variable "project" {
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
