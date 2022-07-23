module "rds" {
  source = "../modules/rds"

  env                         = local.env
  project                     = local.project
  vpc_id                      = module.vpc.vpc_id
  azs                         = local.azs_names
  subnet_ids                  = module.vpc.private_subnet_ids
  backup_retention_period     = 1
  cluster_instance_class      = "db.t3.medium"
  cluster_deletion_protection = false
  cluster_skip_final_snapshot = true
  cluster_maintenance_window  = "Tue:14:30-Tue:15:00"

  db_master_username    = "dev_user"
  db_instance_count     = 2
  db_port               = local.db_port
  db_maintenance_window = ["Mon:15:25-Mon:15:55", "Wed:15:25-Wed:15:55"]

  sg_port_rules = local.sg_port_rules_rds

  depends_on = [
    module.firehose_log_stream_rds
  ]
}
