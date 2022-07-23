output "rds_cluster_id" {
  value = aws_rds_cluster.main.id
}

output "rds_cluster_username" {
  value = aws_rds_cluster.main.master_username
}

output "rds_cluster_password" {
  value     = local.master_db_password
  sensitive = true
}

output "rds_cluster_writer_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "rds_cluster_reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
}

output "rds_cluster_database_name" {
  value = aws_rds_cluster.main.database_name
}

output "security_group_id" {
  value = module.security_group.id
}
