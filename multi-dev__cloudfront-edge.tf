


################################################
# Lambda function - Cloudfront Edge Router

resource "aws_lambda_function" "multi" {
  function_name = "cloudfront-edge--multi"
  role          = aws_iam_role.multi.arn
  handler       = "index.handler"

  # s3_bucket = aws_s3_bucket.invalidator-artifacts
  # s3_key    = "latest.zip"
  filename = "latest.zip"

  # runtime = "go1.x"
  runtime = "nodejs14.x"
  publish = true
}


resource "aws_iam_role" "multi" {
  name               = "cloudfront-edge--multi"
  assume_role_policy = data.aws_iam_policy_document.multi.json
}

data "aws_iam_policy_document" "multi" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
    effect = "Allow"
  }
}


resource "aws_iam_role_policy_attachment" "multi_execution_role" {
  role       = aws_iam_role.multi.name
  policy_arn = aws_iam_policy.multi.arn
}

resource "aws_iam_policy" "multi" {
  name        = "LambdaEdgeMultiLogging"
  description = "Enable CloudFront Edge lambda function logging."

  policy = data.aws_iam_policy_document.edge-multi-logging.json
}


data "aws_iam_policy_document" "edge-multi-logging" {

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

}

