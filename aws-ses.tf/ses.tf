resource "aws_ses_domain_identity" "ses" {
  domain = local.domain_name
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = local.domain_name
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.ses.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.ses.domain}"
}
