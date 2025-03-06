resource "aws_wafv2_web_acl" "this" {
  name  = "${var.name_prefix}-acl"
  scope = var.scope

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.managed_rules

    content {
      name = rule.value.name
      priority = rule.value.priority

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name = rule.value.name
          vendor_name = "AWS"

          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_overrides

            content {
              name = rule_action_override.value.name
              action_to_use {
                dynamic "allow" {
                  for_each = rule_action_override.value.action_to_use == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule_action_override.value.action_to_use == "block" ? [1] : []
                  content {}
                }
                dynamic "captcha" {
                  for_each = rule_action_override.value.action_to_use == "captcha" ? [1] : []
                  content {}
                }
                dynamic "challenge" {
                  for_each = rule_action_override.value.action_to_use == "challenge" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule_action_override.value.action_to_use == "count" ? [1] : []
                  content {}
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name = "${rule.key}-metric"
        sampled_requests_enabled = rule.value.sampled_requests_enabled
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = "${var.name_prefix}-acl-metric"
    sampled_requests_enabled   = var.sampled_requests_enabled
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  for_each = var.association_resource_arns

  web_acl_arn  = aws_wafv2_web_acl.this.arn
  resource_arn = each.value
}
