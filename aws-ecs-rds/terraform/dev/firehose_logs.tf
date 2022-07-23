module "firehose_log_stream_rds" {
  source = "../modules/firehose_logs"

  env                          = local.env
  log_bucket_arn               = module.s3_logs.bucket_arn
  log_bucket_id                = module.s3_logs.bucket_id
  iam_role_firehose_arn        = module.iam_role_firehose.role_arn
  iam_role_cloudwatch_logs_arn = module.iam_role_cloudwatch_logs.role_arn

  # NOTE: 本当は${local.cluster_name}-${local.env}を${module.rds.cluster_identifier}にしたいがrdsの作成前にfirehoseを作成しないといけないため、これで実装してます
  # rdsデフォルトのロググループではなく、aws_cloudwatch_log_groupロググループを作成するため
  # See: https://github.com/hashicorp/terraform-provider-aws/issues/5348
  log_groups = [
    { stream_name = "rds-audit", log_group_name = "/aws/rds/cluster/${local.project}-${local.env}/audit" },
    { stream_name = "rds-error", log_group_name = "/aws/rds/cluster/${local.project}-${local.env}/error" },
    { stream_name = "rds-general", log_group_name = "/aws/rds/cluster/${local.project}-${local.env}/general" },
    { stream_name = "rds-slowquery", log_group_name = "/aws/rds/cluster/${local.project}-${local.env}/slowquery" }
  ]
}

module "firehose_log_stream_ecs" {
  source = "../modules/firehose_logs"

  env                          = local.env
  log_bucket_arn               = module.s3_logs.bucket_arn
  log_bucket_id                = module.s3_logs.bucket_id
  iam_role_firehose_arn        = module.iam_role_firehose.role_arn
  iam_role_cloudwatch_logs_arn = module.iam_role_cloudwatch_logs.role_arn
  log_groups = [
    { stream_name = "ecs-app", log_group_name = "/aws/ecs/app/${local.env}" },
    { stream_name = "ecs-nginx", log_group_name = "/aws/ecs/nginx/${local.env}" },
    { stream_name = "ecs-bastion", log_group_name = "${local.log_group_bastion}/${local.env}" }
  ]
}

module "firehose_log_stream_cloudfront_waf" {
  source = "../modules/firehose_logs"
  providers = {
    aws = aws.cloud_front
  }

  env                          = local.env
  log_bucket_arn               = module.s3_logs.bucket_arn
  log_bucket_id                = module.s3_logs.bucket_id
  iam_role_firehose_arn        = module.iam_role_firehose.role_arn
  iam_role_cloudwatch_logs_arn = module.iam_role_cloudwatch_logs.role_arn
  log_groups = [
    { stream_name = "cloudfront-waf", log_group_name = "/aws/waf/cloudfront/${local.env}" }
  ]
}

module "firehose_log_stream_web_alb_waf" {
  source = "../modules/firehose_logs"

  env                          = local.env
  log_bucket_arn               = module.s3_logs.bucket_arn
  log_bucket_id                = module.s3_logs.bucket_id
  iam_role_firehose_arn        = module.iam_role_firehose.role_arn
  iam_role_cloudwatch_logs_arn = module.iam_role_cloudwatch_logs.role_arn
  log_groups = [
    { stream_name = "web-alb-waf", log_group_name = "/aws/waf/api-alb/${local.env}" }
  ]
}

