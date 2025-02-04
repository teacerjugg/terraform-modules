data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# reference: https://docs.aws.amazon.com/ja_jp/firehose/latest/dev/controlling-access.html#using-iam-s3
data "aws_iam_policy_document" "kinesis_firehose" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]
    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${var.kinesis_firehose_name}",
    ]
  }

  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "logs:PutLogEvents",
  #   ]
  #   resources = [
  #     "arn:aws:logs:${data.aws_region.current.name}:${var.aws_account_id}:log-group:/aws/kinesisfirehose/${var.kinesis_firehose_name}:log-stream:*",
  #   ]
  # }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.name_prefix}-kinesis-firehose-policy"
  policy = data.aws_iam_policy_document.kinesis_firehose.json
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-kinesis-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.kinesis_firehose_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.this.arn
    bucket_arn = var.s3_bucket_arn

    buffering_size     = 64
    buffering_interval = var.buffering_interval

    dynamic_partitioning_configuration {
      enabled = true
    }

    prefix              = "data/env=!{partitionKeyFromQuery:env}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/userId=!{partitionKeyFromQuery:userId}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}/"

    processing_configuration {
      enabled = true

      processors {
        type = "RecordDeAggregation"
        parameters {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      }

      processors {
        type = "AppendDelimiterToRecord"
      }

      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{ env: .env, userId: .userId }"
        }
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
      }
    }
  }
}
