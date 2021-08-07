

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

}



data "archive_file" "invalidator-v2" {
  type        = "zip"
  source_dir  = "./lambdas/cloudfront-invalidator-from-trigger"
  output_path = "./lambdas/invalidator_v2.zip"
}


resource "aws_lambda_function" "invalidator-v2" {
  function_name = "cloudfront-invalidator-v2"
  description   = "Invalidates cloudfront distributions from an S3 bucket trigger."
  role          = aws_iam_role.invalidator.arn
  handler       = "index.handler"

  filename         = "./lambdas/invalidator_v2.zip"
  source_code_hash = data.archive_file.invalidator-v2.output_base64sha256

  runtime = "nodejs14.x"
  publish = true

  environment {
    variables = {
      # Cloudfront ID => S3 bucket name
      for s in local.static_sites : aws_cloudfront_distribution.site[s.hostname].id => aws_s3_bucket.site[s.hostname].bucket
    }
  }

}

resource "aws_s3_bucket_notification" "invalidator-v2" {
  for_each = local.static_sites
  bucket   = aws_s3_bucket.site[each.key].id

  lambda_function {
    # Fire Lambda only if the index.html file is updated
    lambda_function_arn = aws_lambda_function.invalidator-v2.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
    ]
    filter_prefix = "index.html"
  }
}

resource "aws_lambda_permission" "allow_bucket_lambda_alias" {
  for_each      = local.static_sites
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invalidator-v2.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.site[each.key].arn
}


resource "aws_iam_role_policy_attachment" "lambda-policy-attach-v2" {
  role       = aws_iam_role.invalidator.name
  policy_arn = aws_iam_policy.lambda-permissions-policy.arn
}
