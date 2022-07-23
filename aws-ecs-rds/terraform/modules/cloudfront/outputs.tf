output "origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.static_web.iam_arn
}

output "arn" {
  value = aws_cloudfront_distribution.static_web.arn
}

output "distribution_id" {
  value = aws_cloudfront_distribution.static_web.id
}
