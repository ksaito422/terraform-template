data "aws_route53_zone" "host_zone" {
  name = local.domain_name
}

resource "aws_route53_record" "ses_record" {
  zone_id = data.aws_route53_zone.host_zone.zone_id
  name    = "_amazonses.${data.aws_route53_zone.host_zone.name}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses.verification_token}"]
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.host_zone.zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${data.aws_route53_zone.host_zone.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "dmarc_record" {
  zone_id = data.aws_route53_zone.host_zone.zone_id
  name    = "_dmarc.${data.aws_route53_zone.host_zone.name}"
  type    = "TXT"
  ttl     = "60"
  # dmarcのハンドリングについては下記リンク先を参照
  # https://cha-shu00.hatenablog.com/entry/2022/03/06/175823
  records = ["v=DMARC1;p=none;rua=mailto:dmarc-reports@${data.aws_route53_zone.host_zone.name}"]
}

resource "aws_route53_record" "mail_from_mx" {
  zone_id = data.aws_route53_zone.host_zone.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"]
}

resource "aws_route53_record" "spf" {
  zone_id = data.aws_route53_zone.host_zone.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

# ヘッダFROMのドメインもSPFレコードに登録するのは、キャリアメールが届くようにするため
# https://qiita.com/shouta-dev/items/a33c55e0df154012c557
resource "aws_route53_record" "spf_career" {
  zone_id = data.aws_route53_zone.host_zone.zone_id
  name    = aws_ses_domain_identity.ses.domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}
