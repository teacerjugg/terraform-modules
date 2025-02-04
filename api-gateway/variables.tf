variable "name_prefix" {
  type     = string
  nullable = false
}

variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_gateway_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = null
}

variable "api_gateway_stage_name" {
  description = "The name of the API Gateway Stage"
  type        = string
  default     = "dev"
}

variable "cors_allow_origin_regex" {
  type = string
  default = "^http(s?)://.*\.?(example\.com)(:?\d+)?"
}

variable "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose"
  type        = string
}

variable "kinesis_firehose_name" {
  description = "The name of the Kinesis Firehose"
  type        = string
}

variable "enable_domain" {
  description = "Enable domain name for the API Gateway"
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "The name of the Route53 zone"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the API Gateway"
  type        = string
  default     = null
}

variable "regional_certificate_arn" {
  description = "The ARN of the ACM regional certificate"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Enable logging for the API Gateway"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  type        = string
}

locals {
  logging_level = var.enable_logging ? "ERROR" : "OFF"
}
