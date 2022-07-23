output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "dependency" {
  value = aws_acm_certificate_validation.validation
}
