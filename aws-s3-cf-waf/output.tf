output "cloud_front_destribution_domain_name" {
  value = aws_cloudfront_distribution.static-www.domain_name
}
