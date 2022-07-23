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
# WAF v2
# AWS managed rule list
# See: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html
################################################################################

resource "aws_wafv2_web_acl" "main" {
  name  = "aws-wafv2-web-acl-${var.usage}-${var.env}"
  scope = var.waf_scope

  default_action {
    allow {}
  }

  rule {
    name     = "aws-managed-rules-common-rule-set"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-managed-rules-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-sqli-rule-set"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-managed-rules-sqli-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-linux-rule-set"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-managed-rules-linux-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-rules-bot-control-rule-set"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-managed-rules-bot-control-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "request-body-size-rules"
    priority = 40

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GE"
        size                = var.body_size_constrains
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "request-body-size-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-base-limit-rules"
    priority = 50

    action {
      block {}
    }

    statement {
      # 5分間に許容する同一IPからのリクエスト上限
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-base-limit-rules"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name = "${var.env}-waf-${var.usage}"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-wafv2-web-acl-${var.usage}"
    sampled_requests_enabled   = true
  }
}

################################################################################
# WAF v2 association
################################################################################

resource "aws_wafv2_web_acl_association" "main" {
  count = var.waf_scope == "REGIONAL" ? 1 : 0

  resource_arn = var.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

################################################################################
# WAF v2 logging configuration
################################################################################

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [var.cloudwatch_log_group_arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ALL"
    }
  }
}

