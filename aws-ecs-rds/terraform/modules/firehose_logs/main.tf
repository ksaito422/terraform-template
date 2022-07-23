################################################################################
# for provider change
# see : https://github.com/hashicorp/terraform-provider-aws/issues/22586
#       https://www.terraform.io/language/modules/develop/providers
################################################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

################################################################################
# CloudWatch log group
################################################################################

resource "aws_cloudwatch_log_group" "main" {
  for_each = { for i in var.log_groups : i.stream_name => i }

  name              = each.value.log_group_name
  retention_in_days = 30

  tags = {
    Name = "${var.env}-${each.value.stream_name}-log-group"
  }
}

################################################################################
# Kinesis Data Firehose
################################################################################

resource "aws_kinesis_firehose_delivery_stream" "main" {
  for_each = { for i in var.log_groups : i.stream_name => i }

  name        = "${var.env}-${each.value.stream_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.iam_role_firehose_arn
    bucket_arn          = var.log_bucket_arn
    buffer_size         = 5
    buffer_interval     = 300
    prefix              = join("", [each.value.stream_name, "/!{timestamp:yyyy-MM-dd}/"])
    error_output_prefix = join("", [each.value.stream_name, "/result=!{firehose:error-output-type}/!{timestamp:yyyy-MM-dd}/"])
    compression_format  = "GZIP"
  }

  tags = {
    Name = "${var.env}-${each.value.stream_name}"
  }
}

################################################################################
# CloudWatch logs
################################################################################

resource "aws_cloudwatch_log_subscription_filter" "main" {
  for_each = { for i in var.log_groups : i.stream_name => i }

  name            = "${var.env}-${each.value.stream_name}-filter"
  log_group_name  = each.value.log_group_name
  filter_pattern  = ""
  destination_arn = element([for i in aws_kinesis_firehose_delivery_stream.main : i.arn], index(var.log_groups, each.value))
  role_arn        = var.iam_role_cloudwatch_logs_arn
}

