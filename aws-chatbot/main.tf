data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "invoke_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [var.lambda_function_arn]
  }
}

resource "aws_iam_policy" "invoke_lambda" {
  name   = "${var.name_prefix}-invoke-lambda-policy"
  policy = data.aws_iam_policy_document.invoke_lambda.json
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-chatbot-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.invoke_lambda.arn
}

resource "awscc_chatbot_slack_channel_configuration" "this" {
  configuration_name = var.configuration_name
  iam_role_arn       = aws_iam_role.this.arn

  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id

  guardrail_policies = [
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
  ]
}
