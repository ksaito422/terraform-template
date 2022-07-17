variable "project" {
  type = string
}

variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "ecr_base_uri" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet" {
  type = list(string)
}
