variable "env" {
  type = string
}

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "backup_retention_period" {
  type    = number
  default = 1
}

variable "cluster_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "cluster_deletion_protection" {
  type = bool
}

variable "cluster_maintenance_window" {
  type = string
}

variable "cluster_skip_final_snapshot" {
  type = bool
}

variable "db_master_username" {
  type = string
}

variable "db_instance_count" {
  type = number
}

variable "db_maintenance_window" {
  type = list(string)
}

## db_master_passwordはrds module内で自動生成している

variable "db_port" {
  type = number
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

locals {
  db_instance_count_check = (var.db_instance_count != length(var.db_maintenance_window)) ? tobool("The db_maintenance_window's length must be a equal db_instance_count.") : true
}
