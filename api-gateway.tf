# ################################################
# # API Gateway

# resource "aws_api_gateway_rest_api" "api" {
#   for_each    = local.apis
#   name        = "${each.key}--gateway"
#   description = "Proxy to handle requests to our API"
# }

# resource "aws_api_gateway_resource" "resource" {
#   for_each    = local.apis
#   rest_api_id = aws_api_gateway_rest_api.api[each.key].id
#   parent_id   = aws_api_gateway_rest_api.api[each.key].root_resource_id
#   path_part   = "{proxy+}"
# }

# resource "aws_api_gateway_method" "method" {
#   for_each      = local.endpoints
#   rest_api_id   = aws_api_gateway_rest_api.api[each.value.hostname].id
#   resource_id   = aws_api_gateway_resource.resource[each.value.hostname].id
#   http_method   = each.value.method
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "integration" {
#   for_each                = local.endpoints
#   rest_api_id             = aws_api_gateway_rest_api.api[each.value.hostname].id
#   resource_id             = aws_api_gateway_resource.resource[each.value.hostname].id
#   http_method             = aws_api_gateway_method.method[each.key].http_method
#   integration_http_method = each.value.method
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.tf_mombo-lambda.invoke_arn
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   for_each = local.apis
#   depends_on = [
#     aws_api_gateway_integration.integration,
#   ]

#   rest_api_id = aws_api_gateway_rest_api.api[each.key].id
#   stage_name  = "v1"
# }

# resource "aws_lambda_permission" "apigw" {
#   statement_id = "AllowAPIGatewayInvoke"
#   action       = "lambda:InvokeFunction"

#   function_name = aws_lambda_function.tf_mombo-lambda.function_name
#   principal     = "apigateway.amazonaws.com"

#   # The /*/* portion grants access from any method on any resource
#   # within the API Gateway "REST API".
#   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

#   depends_on = [
#     aws_api_gateway_rest_api.api,
#     aws_lambda_function.tf_mombo-lambda,
#   ]
# }

# # resource "aws_api_gateway_domain_name" "example" {
# #   certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
# #   domain_name     = "api.vincenzo.cloud"
# # }


# ################################################
# # Lambda function - Invalidates cloudfront

# resource "aws_lambda_function" "tf_mombo-lambda" {
#   # filename      = "lambda_function_payload.zip"
#   function_name = "tf-mombo-post-deploy-v2"
#   role          = aws_iam_role.tf_mombo_lambda_role.arn
#   handler       = "index.handler"

#   # The filebase64sha256() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#   #   source_code_hash = base64sha256(file("lambda_function_payload.zip"))
#   s3_bucket = var.s3_lambda_artifacts
#   s3_key    = "latest.zip"

#   runtime = "nodejs14.x"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }

#   depends_on = [
#     aws_s3_bucket.api_gateway_lambdas
#   ]
# }

# resource "aws_iam_role" "tf_mombo_lambda_role" {
#   name               = "tf_mombo_lambda_role"
#   assume_role_policy = data.aws_iam_policy_document.mombo_lambda_role_doc.json
# }

# data "aws_iam_policy_document" "mombo_lambda_role_doc" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#     effect = "Allow"
#   }
# }

# ################################################
# # Lambda permissions

# resource "aws_iam_policy" "lambda-permissions-policy" {
#   name        = "cloudfront-invalidation"
#   description = "Enable cloudfront invalidation"

#   policy = data.aws_iam_policy_document.lambda-permissions.json
# }

# data "aws_iam_policy_document" "lambda-permissions" {

#   statement {
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ]
#     effect    = "Allow"
#     resources = ["*"]
#   }

#   statement {
#     actions = [
#       "cloudfront:CreateInvalidation"
#     ]
#     effect = "Allow"
#     resources = [
#       aws_cloudfront_distribution.mombo-deploy.arn
#     ]
#   }
# }


# resource "aws_iam_role_policy_attachment" "lambda-policy-attach" {
#   role       = aws_iam_role.tf_mombo_lambda_role.name
#   policy_arn = aws_iam_policy.lambda-permissions-policy.arn

#   depends_on = [
#     aws_iam_policy.lambda-permissions-policy
#   ]
# }

# ################################################
# # S3 bucket - lambda artifacts

# resource "aws_s3_bucket" "api_gateway_lambdas" {
#   bucket = var.s3_lambda_artifacts
#   acl    = "private"

#   tags = {
#     Name        = var.project
#     Environment = var.environment
#   }

#   policy = data.aws_iam_policy_document.api_gateway_lambdas_bucket_policy.json
# }



# data "aws_iam_policy_document" "api_gateway_lambdas_bucket_policy" {

#   statement {
#     sid = "PublicReadGetObject"

#     actions = [
#       "s3:GetObject",
#     ]

#     resources = [
#       "arn:aws:s3:::${var.s3_lambda_artifacts}/*",
#     ]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#   }
# }

