################################################################################
# locals
################################################################################

locals {
  family             = "aurora-mysql8.0"
  master_db_password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$?"
}

################################################################################
# Cluster Parameters
################################################################################

resource "aws_db_subnet_group" "main" {
  name       = "subnet-gp-${var.env}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.env}-db-subnet-gp"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "db-pg-${var.env}"
  family = local.family

  parameter {
    name  = "slow_launch_time"
    value = "1"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  name   = "rds-cluster-pg-${var.env}"
  family = local.family

  parameter {
    name         = "character-set-client-handshake"
    value        = "0"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_bin_trust_function_creators"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_allowed_packet"
    value        = "10240000"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_slow_replica_statements"
    value        = "1"
    apply_method = "pending-reboot"
  }

  # see:https://dev.mysql.com/doc/refman/8.0/ja/slow-query-log.html
  parameter {
    name         = "log_slow_admin_statements"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "general_log"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "skip-character-set-client-handshake"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "binlog_format"
    value        = "row"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "binlog_checksum"
    value        = "none"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "long_query_time"
    value        = "1"
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.env}-rds-cluster-pg"
  }
}

################################################################################
# IAM for monitoring
################################################################################

module "iam_role" {
  source = "../iam_role"

  env                = var.env
  role_name          = "${var.project}-aurora-monitoring"
  identifiers        = ["monitoring.rds.amazonaws.com"]
  managed_policy_arn = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}

################################################################################
# Security Group
################################################################################

module "security_group" {
  source = "../security_group"

  name          = "${var.project}-aurora-sg-${var.env}"
  vpc_id        = var.vpc_id
  sg_port_rules = var.sg_port_rules
}

################################################################################
# Key Management Service (KMS)
################################################################################

resource "aws_kms_key" "main" {
  key_usage = "ENCRYPT_DECRYPT"

  # [AWS KMS keys ローテーション - AWS Key Management Service](https://docs.aws.amazon.com/ja_jp/kms/latest/developerguide/rotate-keys.html)
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project}-rds-${var.env}"
  target_key_id = aws_kms_key.main.key_id
}

################################################################################
# Cluster
################################################################################

resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project}-${var.env}"
  availability_zones = var.azs

  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.01.0"

  master_username = var.db_master_username
  master_password = local.master_db_password
  port            = var.db_port
  database_name   = "dev_default"

  backup_retention_period      = var.backup_retention_period # prod=7,stg=1
  preferred_maintenance_window = var.cluster_maintenance_window
  preferred_backup_window      = "19:00-21:00" # jst 04:00-06:00の設定になる

  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn

  apply_immediately                   = true
  iam_database_authentication_enabled = false
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  deletion_protection                 = var.cluster_deletion_protection
  skip_final_snapshot                 = var.cluster_skip_final_snapshot

  db_subnet_group_name            = aws_db_subnet_group.main.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  vpc_security_group_ids          = tolist([module.security_group.id])

  lifecycle {
    ignore_changes = [
      master_password,
      availability_zones,
    ]
  }
  tags = {
    Name = "${var.env}-rds-cluster"
  }

}

resource "aws_rds_cluster_instance" "mysql80" {
  count = var.db_instance_count

  cluster_identifier = aws_rds_cluster.main.id
  identifier         = "${var.project}-${var.env}-${count.index + 1}"

  engine         = aws_rds_cluster.main.engine
  engine_version = aws_rds_cluster.main.engine_version

  instance_class    = var.cluster_instance_class
  apply_immediately = true

  db_subnet_group_name    = aws_rds_cluster.main.db_subnet_group_name
  db_parameter_group_name = aws_db_parameter_group.main.name

  monitoring_role_arn = module.iam_role.role_arn
  monitoring_interval = 5

  publicly_accessible          = false
  preferred_maintenance_window = var.db_maintenance_window[count.index]

  tags = {
    Name = "${var.env}-aurora-cluster-mysql-${count.index + 1}"
  }

}
