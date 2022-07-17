resource "aws_acm_certificate" "example" {
  domain_name               = aws_route53_record.example.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_route53_record" "example_certificate" {
#   name = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
#   type = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
#   records = [aws_acm_certificate.example.domain_validation_iptions[0].resource_record_value]
#   zone_id = data.aws_route53_zone.example.id
#   ttl = 60
# }
resource "aws_route53_record" "example_certificate" {
  # "saito.page", "*.saito.page"の2つを登録するのでcount=2
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = aws_route53_zone.test_example.id
  records         = [each.value.record]
  ttl             = 60
}
