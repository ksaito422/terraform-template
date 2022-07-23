variable "route53_zone_id" {
  type = string
}

variable "route53_name" {
  type = string
}

variable "type" {
  type = string
}

variable "records" {
  type = list(string)
}

variable "ttl" {
  type    = number
  default = 60
}