################################################################################
# to fetch policy id
# managed policy id list
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
################################################################################

locals {
  origin_request_policy_id  = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  security_header-policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
}

################################################################################
# for provider change
# see : https://github.com/hashicorp/terraform-provider-aws/issues/22586
#       https://www.terraform.io/language/modules/develop/providers
################################################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

################################################################################
# Managed Cache Policy
################################################################################

data "aws_cloudfront_origin_request_policy" "main" {
  # NOTE: nameだとpolicy idが取得できないバグのため、idで取得している
  # providerのバグ直れば、nameで取得したほうが見やすい
  id = local.origin_request_policy_id
  # name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "main" {
  # NOTE: nameだとpolicy idが取得できないバグのため、idで取得している
  # providerのバグ直れば、nameで取得したほうが見やすい
  id = var.cache_policy
  # name = var.cache_policy
}

################################################################################
# Managed Cache Policy
################################################################################

data "aws_cloudfront_response_headers_policy" "main" {
  # NOTE: nameだとpolicy idが取得できないバグのため、idで取得している
  id = local.security_header-policy_id
}

################################################################################
# CloudFront Static website hosting
################################################################################

resource "aws_cloudfront_distribution" "static_web" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = var.s3_bucket_id
    s3_origin_config {
      # CloudFrontからのアクセスのみを許可する
      origin_access_identity = aws_cloudfront_origin_access_identity.static_web.cloudfront_access_identity_path
    }
  }

  web_acl_id = var.waf_web_acl_arn

  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class

  logging_config {
    bucket          = var.bucket_domain_name
    include_cookies = true
    prefix          = var.log_prefix
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_id

    # Managed cache policyの利用
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.main.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.main.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.main.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.main.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [var.domain_name]

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "${var.env}-cloudfront"
  }

  depends_on = [
    data.aws_cloudfront_origin_request_policy.main,
    data.aws_cloudfront_cache_policy.main
  ]
}

resource "aws_cloudfront_origin_access_identity" "static_web" {
  comment = "${var.env}-static_web"
}

################################################################################
# CloudFront Functions
################################################################################

resource "aws_cloudfront_function" "main" {
  name    = "${var.env}-url-normalization"
  runtime = "cloudfront-js-1.0"
  comment = "Appends index.html to request URLs"
  publish = true
  code    = var.cloudfront_functions
}

################################################################################
# Route53 Create A records
################################################################################

module "static_web" {
  source = "../route53_record_alias"

  route53_zone_id        = var.zone_id
  route53_name           = var.domain_name
  alias_name             = aws_cloudfront_distribution.static_web.domain_name
  alias_zone_id          = aws_cloudfront_distribution.static_web.hosted_zone_id
  evaluate_target_health = false
}
