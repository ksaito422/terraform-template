module "cloudfront" {
  source = "../modules/cloudfront"
  providers = {
    aws = aws.cloud_front
  }

  env                   = local.env
  domain_name           = local.domain_web
  s3_bucket_domain_name = module.s3_static_web.bucket_domain_name
  s3_bucket_id          = module.s3_static_web.bucket_id
  price_class           = "PriceClass_All"
  acm_certificate_arn   = module.acm_cloudfront.certificate_arn
  zone_id               = data.aws_route53_zone.main.zone_id
  waf_web_acl_arn       = module.waf_cloudfront.web_acl_arn
  cache_policy          = local.caching_disabled
  cloudfront_functions  = file("${path.module}/functions/cloudfront_function_web.js")
  bucket_domain_name    = module.s3_logs.bucket_domain_name
  log_prefix            = "cloudfront_web/"

  depends_on = [
    # ACMで証明書のValidationStatus=Successでないとcloudfrontの作成に失敗するた依存関係を明記
    module.acm_cloudfront
  ]
}
