variable "name_prefix" {
  type     = string
  nullable = false
}

variable "scope" {
  type    = string
  default = "REGIONAL"
}

variable "allow_ip_addresses" {
  type    = list(string)
  default = []
}

variable "default_action" {
  type    = string
  default = "allow"
}

variable "cloudwatch_metrics_enabled" {
  type    = bool
  default = true
}

variable "sampled_requests_enabled" {
  type    = bool
  default = true
}

variable "enable_allow_ips_rule" {
  type    = bool
  default = false
}

variable "managed_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    cloudwatch_metrics_enabled = optional(bool, true)
    sampled_requests_enabled   = optional(bool, true)
    rule_action_overrides = optional(list(object({
      name          = string
      action_to_use = string
    })), [])
  }))
  default = {
    aws-managed-rules-amazon-ip-reputation-list = {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 100
    }
    aws-managed-rules-common-rule-set = {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 200
    }
    aws-managed-rules-php-rule-set = {
      name     = "AWSManagedRulesPHPRuleSet"
      priority = 300
    }
    aws-managed-rules-sqli-rule-set = {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 400
    }
    aws-managed-rules-known-bad-inputs-rule-set = {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 500
    }
    aws-managed-rules-linux-rule-set = {
      name     = "AWSManagedRulesLinuxRuleSet"
      priority = 600
    }
    aws-managed-rules-unix-rule-set = {
      name     = "AWSManagedRulesUnixRuleSet"
      priority = 700
    }
  }
}

variable "association_resource_arns" {
  type    = map(string)
  default = {}
}
