module "waf_web_alb" {
  source = "../modules/waf"

  env                      = local.env
  usage                    = "api"
  waf_scope                = "REGIONAL"
  resource_arn             = module.alb_api.arn
  body_size_constrains     = local.body_size_constrains_byte
  cloudwatch_log_group_arn = module.firehose_log_stream_web_alb_waf.log_group_arn[0]
}

module "waf_cloudfront" {
  source = "../modules/waf"
  providers = {
    aws = aws.cloud_front
  }

  env                      = local.env
  usage                    = "web"
  waf_scope                = "CLOUDFRONT"
  cloudwatch_log_group_arn = module.firehose_log_stream_cloudfront_waf.log_group_arn[0]
}

