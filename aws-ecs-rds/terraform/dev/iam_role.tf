# firehose,cloudwatch_logsのポリシーはこちら参考
# See: https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#FirehoseExample
module "iam_role_firehose" {
  source = "../modules/iam_role"

  env         = local.env
  role_name   = "firehose-to-s3"
  identifiers = ["firehose.amazonaws.com"]
  policies = [
    {
      name = "kinesis-data-firehose"
      actions = [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      resources = [
        "arn:aws:s3:::${module.s3_logs.bucket_id}",
        "arn:aws:s3:::${module.s3_logs.bucket_id}/*"
      ]
    }
  ]
}

module "iam_role_cloudwatch_logs" {
  source = "../modules/iam_role"

  env       = local.env
  role_name = "cloudwatch-logs-to-firehose"
  identifiers = [
    "logs.${data.aws_region.current.name}.amazonaws.com",
    "logs.us-east-1.amazonaws.com"
  ]
  policies = [
    {
      name    = "cloudwatch-logs"
      actions = ["firehose:*"],
      resources = [
        "arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
        "arn:aws:firehose:us-east-1:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  ]
  condition = [{
    test     = "StringLike"
    variable = "aws:SourceArn"
    values = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
    ]
  }]
}

module "iam_role_ecs_task_execution_role" {
  source = "../modules/iam_role"

  env         = local.env
  role_name   = "ecs-task-execution-role"
  identifiers = ["ecs-tasks.amazonaws.com"]
  policies = [
    {
      name = "ecs-task-execution-policy"
      actions = [
        "ecs:ListClusters",
        "ecs:ListContainerInstances",
        "ecs:DescribeContainerInstances"
      ],
      resources = ["*"]
    }
  ]
  managed_policy_arn = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

module "iam_role_ecs_task_role" {
  source = "../modules/iam_role"

  env         = local.env
  role_name   = "ecs-task-role"
  identifiers = ["ecs-tasks.amazonaws.com"]
  policies = [
    {
      name = "ecs-task-app-policy",
      actions = [
        "s3:AbortMultipartUpload",
        "s3:Get*",
        "s3:List*",
        "s3:Put*",
        "ses:*"
      ],
      resources = [
        "arn:aws:s3:::${module.s3_images.bucket_id}",
        "arn:aws:s3:::${module.s3_images.bucket_id}/*",
        "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      ]
    },
    {
      name = "ecs-task-bastion-policy",
      actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      resources = ["*"]
    },
    {
      name = "ecs-task-scheduled-policy",
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      resources = ["*"]
    }
  ]
}

