variable "name_prefix" {
  type     = string
  nullable = false
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
  default     = null
}

variable "slack_token" {
  description = "The Slack token"
  type        = string
}

variable "slack_channel" {
  description = "The Slack channel"
  type        = string
}

variable "spreadsheet_id" {
  description = "The Google Spreadsheet ID"
  type        = string
  nullable    = false
}

variable "google_credential" {
  description = "The GCP Service Account credential"
  type        = string
  nullable    = false
}

locals {
  lambda_bin_name = "bootstrap"

  s3_event_slack_notification_lambda_project_name = "s3-event-slack-notification"
  s3_event_slack_notification_lambda_source_path  = "${path.module}/../../app/${local.s3_event_slack_notification_lambda_project_name}"
  s3_event_slack_notification_lambda_bin_path     = "${local.s3_event_slack_notification_lambda_source_path}/target/lambda/${local.s3_event_slack_notification_lambda_project_name}/${local.lambda_bin_name}"
  s3_event_slack_notification_lambda_zip_path     = "${local.s3_event_slack_notification_lambda_bin_path}.zip"

  create_csv_lambda_project_name = "create-csv"
  create_csv_lambda_source_path  = "${path.module}/../../app/${local.create_csv_lambda_project_name}"
  create_csv_lambda_bin_path     = "${local.create_csv_lambda_source_path}/target/lambda/${local.create_csv_lambda_project_name}/${local.lambda_bin_name}"
  create_csv_lambda_zip_path     = "${local.create_csv_lambda_bin_path}.zip"
}
