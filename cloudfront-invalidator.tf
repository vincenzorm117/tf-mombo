################################################
# API Gateway

resource "aws_api_gateway_rest_api" "invalidator" {
  name        = "cloudfront-invalidator--gateway"
  description = "Proxy to handle requests to our API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "invalidator" {
  rest_api_id = aws_api_gateway_rest_api.invalidator.id
  parent_id   = aws_api_gateway_rest_api.invalidator.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "invalidator" {
  rest_api_id   = aws_api_gateway_rest_api.invalidator.id
  resource_id   = aws_api_gateway_resource.invalidator.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "invalidator" {
  rest_api_id             = aws_api_gateway_rest_api.invalidator.id
  resource_id             = aws_api_gateway_resource.invalidator.id
  http_method             = aws_api_gateway_method.invalidator.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.invalidator.invoke_arn
}

resource "aws_api_gateway_deployment" "invalidator" {
  rest_api_id = aws_api_gateway_rest_api.invalidator.id
  stage_name  = "v1"

  depends_on = [
    aws_api_gateway_integration.invalidator,
  ]
}




################################################
# Lambda function - Invalidates cloudfront

resource "aws_lambda_function" "invalidator" {
  function_name = "cloudfront-invalidator"
  role          = aws_iam_role.invalidator.arn
  handler       = "main"

  # s3_bucket = aws_s3_bucket.invalidator-artifacts
  # s3_key    = "latest.zip"
  filename = "latest.zip"

  runtime = "go1.x"

  # depends_on = [
  #   aws_s3_bucket.invalidator-artifacts
  # ]
}


################################################
# Lambda Role

resource "aws_iam_role" "invalidator" {
  name               = "cloudfront-invalidator"
  assume_role_policy = data.aws_iam_policy_document.invalidator.json
}

data "aws_iam_policy_document" "invalidator" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}


################################################
# Lambda permissions

resource "aws_iam_role_policy_attachment" "lambda-policy-attach" {
  role       = aws_iam_role.invalidator.name
  policy_arn = aws_iam_policy.lambda-permissions-policy.arn

  depends_on = [
    aws_iam_policy.lambda-permissions-policy
  ]
}


resource "aws_iam_policy" "lambda-permissions-policy" {
  name        = "cloudfront-invalidation"
  description = "Enable cloudfront invalidation, S3 artifact deployment, and logging."

  policy = data.aws_iam_policy_document.invalidator-permissions.json
}


data "aws_iam_policy_document" "invalidator-permissions" {

  statement {
    sid = "Logging"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "CloudfrontInvalidation"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    effect = "Allow"
    resources = [
      for cf in aws_cloudfront_distribution.site : cf.arn
    ]
  }

  statement {
    sid = "PullingArtifacts"
    actions = [
      "s3:GetObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.invalidator-artifacts.arn}/*",
    ]
  }
}



################################################
# S3 bucket - lambda artifacts and permissions

resource "aws_s3_bucket" "invalidator-artifacts" {
  bucket = "cloudfront-invalidator-artifacts"
  acl    = "private"
}


################################################
# API Gateway Lambda function access


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invalidator.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.invalidator.execution_arn}/*/*"
}

# resource "aws_api_gateway_domain_name" "example" {
#   certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
#   domain_name     = "api.vincenzo.cloud"
# }