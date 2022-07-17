# data "aws_iam_policy_document" "codepipeline" {
#   statement {
#     effect = "Allow"
#     resources = ["*"]
#
#     actions = [
#       "s3:PutObject",
#       "s3:GetObject",
#       "s3:GetObjectVersion",
#       "s3:GetBucketVersioning",
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild",
#       "ecs:DescribeServices",
#       "ecs:DescribeTaskDefinition",
#       "ecs:ListTasks",
#       "ecs:RegisterTaskDefinition",
#       "ecs:UpdateService",
#       "iam:PassRole",
#     ]
#   }
# }
#
# module "codepipeline_role" {
#   source= "./modules/iam_role"
#
#   name = "codepipeline"
#   identifier = "codepipeline.amazonaws.com"
#   policy = data.aws_iam_policy_document.codepipeline.json
# }
#
# resource "aws_s3_bucket" "artifact" {
#   bucket = "artifact-pragmatic-terraform"
#
#   lifecycle_rule {
#     enabled = true
#
#     expiration {
#       days = "180"
#     }
#   }
# }
