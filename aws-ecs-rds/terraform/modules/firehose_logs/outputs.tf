output "log_group_arn" {
  value = [for i in aws_cloudwatch_log_group.main : i.arn]
}

