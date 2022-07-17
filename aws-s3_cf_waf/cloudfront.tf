# SSL証明書をアタッチするために既存のルートドメインのリソースを参照
data "aws_acm_certificate" "acm_cert" {
  provider = aws.virginia
  domain   = local.domain_name
}

######################################################
# Managed Cache Policy
######################################################

data "aws_cloudfront_origin_request_policy" "this" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "this" {
  name = "Managed-CachingOptimized"
}

######################################################
# CloudFront Static website hosting
######################################################

resource "aws_cloudfront_distribution" "static-www" {
  # managed cache policyを利用する場合に使う
  depends_on = [
    data.aws_cloudfront_origin_request_policy.this,
    data.aws_cloudfront_cache_policy.this
  ]

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.id
    s3_origin_config {
      // CloudFrontからのアクセスのみ許可するようにする
      origin_access_identity = aws_cloudfront_origin_access_identity.static-www.cloudfront_access_identity_path
    }
  }

  web_acl_id = aws_wafv2_web_acl.allow_only_my_vpn.arn

  enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.bucket.id

    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.this.id
    cache_policy_id          = data.aws_cloudfront_cache_policy.this.id

    # Legacy Cache Policyで定義する場合に利用する
    # forwarded_values {
    #   query_string = false
    #
    #   cookies {
    #     forward = "whitelist"
    #     whitelisted_names = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    #
    #   }
    # }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  aliases = ["${var.site_domain}"]

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn      = data.aws_acm_certificate.acm_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "${local.env}-cloudfront"
  }
}

resource "aws_cloudfront_origin_access_identity" "static-www" {}
