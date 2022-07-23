module "iam_user_cloudfront_deploy" {
  source = "../modules/iam_user"

  env       = local.env
  user_name = local.cloud_front.user_name

  policies = [
    {
      name = "cloudfront-deploy-s3-access"
      actions = [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetBucketLocation"
      ],
      resources = [
        "arn:aws:s3:::${module.s3_static_web.bucket_id}",
        "arn:aws:s3:::${module.s3_static_web.bucket_id}/*"
      ],
      condition = []
    },
    {
      name = "cloudfront-deploy-create-invalidation"
      actions = [
        "cloudfront:CreateInvalidation"
      ],
      resources = [
        "*"
      ],
      condition = []
    }
  ]
}

module "iam_user_app_deploy" {
  source = "../modules/iam_user"

  env       = local.env
  user_name = local.app.user_name

  policies = [
    {
      name = "app-deploy"
      actions = [
        "ecs:*",
        "ecr:*",
        "events:*",
        "cloudtrail:LookupEvents",
        "ecs:RegisterTaskDefinition",
        "iam:PassRole",
        "logs:CreateLogGroup"
      ],
      resources = [
        "*"
      ],
      condition = []
    },
    {
      name = "app-deploy-servicelinked-role"
      actions = [
        "iam:CreateServiceLinkedRole"
      ],
      resources = [
        "*"
      ],
      condition = [
        {
          test     = "StringEquals"
          variable = "iam:AWSServiceName"
          values   = ["replication.ecr.amazonaws.com"]

        }
      ]
    }
  ]
}
