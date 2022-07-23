################################################################################
# SES
################################################################################

resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

################################################################################
# SES TXT Record
################################################################################

resource "aws_route53_record" "txt" {
  zone_id = var.zone_id
  name    = "_amazonses.${var.zone_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

################################################################################
# SES CNAME Record
################################################################################

resource "aws_route53_record" "cname" {
  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${var.zone_name}"
  type    = "CNAME"
  ttl     = 600
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

