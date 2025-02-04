variable "name_prefix" {
  type     = string
  nullable = false
}

variable "slack_channel_id" {
  description = "The Slack channel ID"
  type        = string
}

variable "slack_workspace_id" {
  description = "The Slack workspace ID"
  type        = string
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  type        = string
}

variable "configuration_name" {
  type     = string
  nullable = false
}
