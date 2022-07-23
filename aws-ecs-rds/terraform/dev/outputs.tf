################################################################################
# for vpc
################################################################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

################################################################################
# for alb
################################################################################

output "alb_api_arn" {
  value = module.alb_api.arn
}

output "alb_target_group_api_arn" {
  value = module.alb_api.target_group_arn
}

################################################################################
# for route53
################################################################################

output "route53_fqdn_api" {
  value = module.route53_record_alias_api.fqdn
}

################################################################################
# for rds
################################################################################

output "rds_master_username" {
  value = module.rds.rds_cluster_username
}

output "rds_master_password" {
  value = nonsensitive(module.rds.rds_cluster_password)
}

output "db_name" {
  value = module.rds.rds_cluster_database_name
}

output "route53_writer_domain" {
  value = module.route53_record_writer.route53_record_name
}

output "route53_reader_domain" {
  value = module.route53_record_reader.route53_record_name
}

################################################################################
# for s3
################################################################################

output "s3_bucket_id_web" {
  value = module.s3_static_web.bucket_id
}

output "s3_bucket_id_image" {
  value = module.s3_images.bucket_id
}

################################################################################
# for ecr
################################################################################

# for nginx
output "ecr_repository_url_for_nginx" {
  value = module.ecr_web.repository_url
}
output "ecr_registry_id_for_nginx" {
  value = module.ecr_web.registry_id
}

# for rails
output "ecr_repository_url_for_app" {
  value = module.ecr_app.repository_url
}
output "ecr_registry_id_for_app" {
  value = module.ecr_app.registry_id
}

# for bastion
output "ecr_repository_url_for_bastion" {
  value = module.ecr_bastion.repository_url
}
output "ecr_registry_id_for_bastion" {
  value = module.ecr_bastion.registry_id
}

################################################################################
# for ecs
################################################################################

output "ecs_task_execution_role_name" {
  value = module.iam_role_ecs_task_execution_role.role_arn
}

output "ecs_task_role" {
  value = module.iam_role_ecs_task_role.role_arn
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_sg_id" {
  value = module.ecs.sg_id
}

################################################################################
# for clound front
################################################################################

output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

################################################################################
# ses
################################################################################

output "ses_domain_identity_arn" {
  value = module.ses.ses_domain_identity_arn
}

################################################################################
# IAM for user
################################################################################

output "cloudfront_deploy_arn" {
  value = module.iam_user_cloudfront_deploy.user_arn
}

output "app_deploy_arn" {
  value = module.iam_user_app_deploy.user_arn
}
