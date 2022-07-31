resource "aws_wafv2_ip_set" "my_vpn" {
  name               = "MyVpn"
  scope              = "CLOUDFRONT"
  provider           = aws.virginia
  ip_address_version = "IPV4"
  # 許可したいIP
  addresses = ["0.0.0.0/0"]

  tags = {
    Name = "${local.env}-waf"
  }
}

resource "aws_wafv2_web_acl" "allow_only_my_vpn" {
  name     = "allow_only_my_vpn"
  scope    = "CLOUDFRONT"
  provider = aws.virginia

  default_action {
    block {}
  }

  rule {
    name     = "allow_only_my_vpn"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.my_vpn.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "allow-only-my-vpn-ips"
      sampled_requests_enabled   = false
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudfront-waf"
    sampled_requests_enabled   = false
  }
}
