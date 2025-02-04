variable "name_prefix" {
  type     = string
  nullable = false
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "kinesis_firehose_name" {
  description = "The name of the Kinesis stream"
  type        = string
}

variable "buffering_interval" {
  description = "The buffering interval"
  type        = number
  default     = 300
}
