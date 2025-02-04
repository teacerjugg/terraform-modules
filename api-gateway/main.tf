data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "api_gateway_kinesis_firehose" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [var.kinesis_firehose_arn]
  }
}

data "aws_iam_policy" "AmazonAPIGatewayPushToCloudWatchLogs" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.enable_logging ? 1 : 0

  name              = var.log_group_name
  retention_in_days = 7
}

resource "aws_iam_policy" "api_gateway_kinesis_firehose" {
  name   = "${var.name_prefix}-api-gateway-kinesis-firehose-policy"
  policy = data.aws_iam_policy_document.api_gateway_kinesis_firehose.json
}

resource "aws_iam_role" "api_gateway_kinesis_firehose" {
  name               = "${var.name_prefix}-api-gateway-kinesis-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "api_gateway_cloudwatch_logs" {
  count = var.enable_logging ? 1 : 0

  name               = "${var.name_prefix}-api-gateway-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_kinesis_firehose" {
  role       = aws_iam_role.api_gateway_kinesis_firehose.name
  policy_arn = aws_iam_policy.api_gateway_kinesis_firehose.arn
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_logs" {
  count = var.enable_logging ? 1 : 0

  role       = aws_iam_role.api_gateway_cloudwatch_logs[0].name
  policy_arn = data.aws_iam_policy.AmazonAPIGatewayPushToCloudWatchLogs.arn
}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_gateway_name
  description = var.api_gateway_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "log"
}

resource "aws_api_gateway_account" "this" {
  count = var.enable_logging ? 1 : 0

  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_logs[0].arn
}

resource "aws_api_gateway_method" "post" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id

  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.post.http_method

  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_settings" "this" {
  count = var.enable_logging ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    logging_level      = local.logging_level
    metrics_enabled    = true
    data_trace_enabled = true
  }

  depends_on = [aws_api_gateway_account.this[0]]
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.post.http_method

  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:firehose:action/PutRecord"
  credentials             = aws_iam_role.api_gateway_kinesis_firehose.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
  }

  request_templates = {
    "application/json" = templatefile("${path.module}/templates/firehose_mapping_template.tftpl", {
      stream_name = var.kinesis_firehose_name
    })
  }

  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_integration_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.post.http_method

  status_code = aws_api_gateway_method_response.post.status_code

  response_templates = {
    "application/json" = templatefile("${path.module}/templates/cors_mapping_template.tftpl", {
      origin_regex = var.cors_allow_origin_regex
    })
  }

  depends_on = [aws_api_gateway_integration.post]
}

# reference: https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/how-to-cors.html
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.options.http_method

  status_code = "200"

  response_models = {
    "application/json" = "Empty",
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOT
    { "statusCode": 200 }
    EOT
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.options.http_method

  status_code       = aws_api_gateway_method_response.options.status_code
  selection_pattern = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
  }

  response_templates = {
    "application/json" = templatefile("${path.module}/templates/cors_mapping_template.tftpl", {})
  }

  depends_on = [aws_api_gateway_integration.options]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode({
      resources = [
        aws_api_gateway_integration.post.id,
        aws_api_gateway_integration_response.post.id,
        aws_api_gateway_integration.options.id,
        aws_api_gateway_integration_response.options.id,
        aws_api_gateway_method.post.id,
        aws_api_gateway_method_response.post.id,
        aws_api_gateway_method.options.id,
        aws_api_gateway_method_response.options.id,
      ]
    }))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.api_gateway_stage_name
  deployment_id = aws_api_gateway_deployment.this.id
}

data "aws_route53_zone" "this" {
  count = var.enable_domain ? 1 : 0

  name         = var.zone_name
  private_zone = false
}

resource "aws_api_gateway_domain_name" "this" {
  count = var.enable_domain ? 1 : 0

  domain_name              = var.domain_name
  regional_certificate_arn = var.regional_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "this" {
  count = var.enable_domain ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.this[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this[0].regional_zone_id
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count = var.enable_domain ? 1 : 0

  api_id      = aws_api_gateway_rest_api.this.id
  domain_name = aws_api_gateway_domain_name.this[0].id
  stage_name  = aws_api_gateway_stage.this.stage_name
  base_path   = aws_api_gateway_stage.this.stage_name
}

# resource "aws_apigatewayv2_api" "this" {
#   name        = var.api_gateway_name
#   description = var.api_gateway_description

#   protocol_type = "HTTP"

#   cors_configuration {
#     allow_headers = ["*"]
#     allow_methods = ["POST"]
#     allow_origins = ["*"]
#   }
# }

# resource "aws_apigatewayv2_integration" "this" {
#   api_id          = aws_apigatewayv2_api.this.id
#   credentials_arn = aws_iam_role.this.arn

#   integration_type   = "HTTP_PROXY"
#   integration_method = "POST"
#   integration_uri    = "arn:aws:apigateway:${data.aws_region.current.name}:firehose:action/PutRecord"
#   # integration_uri = "${var.kinesis_firehose_arn}:action/PutRecord"

#   connection_type = "INTERNET"

#   request_parameters = {
#     "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
#     #   "StreamName"   = var.kinesis_firehose_name
#     #   "Data"         = "$request.body.data"
#     #   "PartitionKey" = "$request.body.user_id"
#   }
#   request_templates = {
#     "application/json" = file("${path.module}/mapping_template.json")
#     #   "application/json" = <<EOF
#     #   {
#     #       "StreamName": "$input.params('stream-name')",
#     #       "Data": "$util.base64Encode($input.json('$.Data'))"
#     #       "PartitionKey": "$input.path('$.PartitionKey')"
#     #   }
#     #   EOF
#   }
# }

# resource "aws_apigatewayv2_route" "this" {
#   api_id    = aws_apigatewayv2_api.this.id
#   route_key = "POST /"

#   target = "integrations/${aws_apigatewayv2_integration.this.id}"
# }

# resource "aws_apigatewayv2_stage" "this" {
#   api_id      = aws_apigatewayv2_api.this.id
#   name        = var.api_gateway_stage_name
#   auto_deploy = true
# }
