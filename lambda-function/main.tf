data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_object" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectLegalHold",
      "s3:GetObjectRetention",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
    ]

    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "get_object" {
  name   = "${var.name_prefix}-get-object-policy"
  policy = data.aws_iam_policy_document.get_object.json
}

resource "aws_iam_role" "s3_event_slack_notification" {
  name               = "${var.name_prefix}-slack-notification-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "s3_event_slack_notification_get_object" {
  role       = aws_iam_role.s3_event_slack_notification.name
  policy_arn = aws_iam_policy.get_object.arn
}

resource "aws_iam_role_policy_attachment" "s3_event_slack_notification_AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.s3_event_slack_notification.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "null_resource" "build_s3_event_slack_notification" {
  triggers = {
    code_diff = join("", [
      for file in fileset(local.s3_event_slack_notification_lambda_source_path, "*/*.rs") : filebase64("${local.s3_event_slack_notification_lambda_source_path}/${file}")
    ])
  }

  provisioner "local-exec" {
    working_dir = local.s3_event_slack_notification_lambda_source_path
    command     = "cargo lambda build --release"
  }
}

data "archive_file" "zip_s3_event_slack_notification" {
  type        = "zip"
  source_file = local.s3_event_slack_notification_lambda_bin_path
  output_path = local.s3_event_slack_notification_lambda_zip_path

  depends_on = [null_resource.build_s3_event_slack_notification]
}

resource "aws_lambda_function" "s3_event_slack_notification" {
  function_name = "${var.name_prefix}-s3-event-slack-notification"

  filename         = data.archive_file.zip_s3_event_slack_notification.output_path
  source_code_hash = data.archive_file.zip_s3_event_slack_notification.output_base64sha256

  role    = aws_iam_role.s3_event_slack_notification.arn
  handler = local.lambda_bin_name
  runtime = "provided.al2023"
  timeout = 5

  environment {
    variables = {
      SLACK_TOKEN       = var.slack_token
      SLACK_CHANNEL     = var.slack_channel
      SPREADSHEET_ID    = var.spreadsheet_id
      GOOGLE_CREDENTIAL = var.google_credential
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "s3_event_slack_notification" {
  function_name                = aws_lambda_function.s3_event_slack_notification.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}

data "aws_iam_policy_document" "put_object" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
    ]

    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "create_presigned_url" {
  statement {
    effect = "Allow"
    actions = [
      "s3:CreatePresignedUrl",
    ]

    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "put_object" {
  name   = "${var.name_prefix}-put-object-policy"
  policy = data.aws_iam_policy_document.put_object.json
}

resource "aws_iam_policy" "create_presigned_url" {
  name   = "${var.name_prefix}-create-presigned-url-policy"
  policy = data.aws_iam_policy_document.create_presigned_url.json
}

resource "aws_iam_role" "create_csv" {
  name               = "${var.name_prefix}-create-csv-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "create_csv_get_object" {
  role       = aws_iam_role.create_csv.name
  policy_arn = aws_iam_policy.get_object.arn
}

resource "aws_iam_role_policy_attachment" "create_csv_put_object" {
  role       = aws_iam_role.create_csv.name
  policy_arn = aws_iam_policy.put_object.arn
}

resource "aws_iam_role_policy_attachment" "create_csv_create_presigned_url" {
  role       = aws_iam_role.create_csv.name
  policy_arn = aws_iam_policy.create_presigned_url.arn
}

resource "aws_iam_role_policy_attachment" "create_csv_AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.create_csv.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "null_resource" "build_create_csv" {
  triggers = {
    code_diff = join("", [
      for file in fileset(local.create_csv_lambda_source_path, "*/*.rs") : filebase64("${local.create_csv_lambda_source_path}/${file}")
    ])
  }

  provisioner "local-exec" {
    working_dir = local.create_csv_lambda_source_path
    command     = "cargo lambda build --release"
  }
}

data "archive_file" "zip_create_csv" {
  type        = "zip"
  source_file = local.create_csv_lambda_bin_path
  output_path = local.create_csv_lambda_zip_path

  depends_on = [null_resource.build_create_csv]
}

resource "aws_lambda_function" "create_csv" {
  function_name = "${var.name_prefix}-create-csv"

  filename         = data.archive_file.zip_create_csv.output_path
  source_code_hash = data.archive_file.zip_create_csv.output_base64sha256

  role    = aws_iam_role.create_csv.arn
  handler = local.lambda_bin_name
  runtime = "provided.al2023"
  timeout = 30

  environment {
    variables = {
      SLACK_TOKEN   = var.slack_token
      SLACK_CHANNEL = var.slack_channel
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "create_csv" {
  function_name                = aws_lambda_function.create_csv.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}

