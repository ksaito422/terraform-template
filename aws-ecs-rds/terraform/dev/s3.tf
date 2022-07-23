module "s3_static_web" {
  source = "../modules/s3"

  env         = local.env
  bucket_name = "${local.bucket_name_prefix}-cloudfront"
  bucket_type = "web"
  bucket_policies = [
    {
      principal_type       = "AWS"
      identifiers          = [module.cloudfront.origin_access_identity]
      allow_resource_name  = "CloudFront"
      bucket_policy_action = ["s3:GetObject"]
    },
    {
      principal_type       = "AWS"
      identifiers          = [module.iam_user_cloudfront_deploy.user_arn]
      allow_resource_name  = "Deploy user"
      bucket_policy_action = ["s3:*"]
    }
  ]
}

module "s3_images" {
  source = "../modules/s3"

  env         = local.env
  domain      = local.domain
  bucket_name = "${local.bucket_name_prefix}-images"
  bucket_type = "image"
  bucket_policies = [
    {
      principal_type       = "Service"
      identifiers          = ["ecs-tasks.amazonaws.com"]
      allow_resource_name  = "ECS"
      bucket_policy_action = ["s3:GetObject", "s3:PutObject"]
    }
  ]
}

module "s3_logs" {
  source = "../modules/s3"

  env         = local.env
  bucket_name = "${local.bucket_name_prefix}-logs"
  bucket_type = "log"
  bucket_policies = [
    {
      principal_type       = "Service"
      identifiers          = ["firehose.amazonaws.com"]
      allow_resource_name  = "Kinesis Data Firehose"
      bucket_policy_action = ["s3:GetObject", "s3:PutObject"]

    },
    {
      principal_type       = "Service"
      identifiers          = ["ecs-tasks.amazonaws.com"]
      allow_resource_name  = "Mysql Dump"
      bucket_policy_action = ["s3:GetObject", "s3:PutObject"]
    }
  ]
}

