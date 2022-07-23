variable "env" {
  type = string
}

variable "log_bucket_arn" {
  type = string
}

variable "log_bucket_id" {
  type = string
}

variable "iam_role_firehose_arn" {
  type = string
}

variable "iam_role_cloudwatch_logs_arn" {
  type = string
}

variable "log_groups" {
  type = list(
    object(
      {
        stream_name    = string,
        log_group_name = string
      }
    )
  )
}
