# resource "aws_s3_bucket" "operation" {
#   bucket = "operation-terraform-training-ks"
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "operation" {
#   bucket = aws_s3_bucket.operation.id
#
#   rule {
#     id = "operation"
#
#     expiration {
#       days = 180
#     }
#
#     status = "Enabled"
#   }
# }
#
# resource "aws_cloudwatch_log_group" "operation" {
#   name = "/operation"
#   retention_in_days = 180
# }
#
# resource "aws_ssm_document" "session_manager_run_shell" {
#   name = "SSM-SessionManagerRunShell"
#   document_type = "Session"
#   document_format = "JSON"
#
#   content = <<EOF
#   {
#     "schemaVersion": "1.0",
#     "description": "Document to hold regional settings for Session Manager",
#     "sessionType": "Standard_Stream"
#     "inputs": {
#       "s3BucketName": "${aws_s3_bucket.operation.id}"
#       "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.operation.name}"
#     }
#   }
# EOF
# }
