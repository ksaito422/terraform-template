variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "holding_count" {
  type = number
}