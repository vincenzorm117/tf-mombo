


################################################
# Lambda function - Cloudfront Edge Router

resource "aws_lambda_function" "edge" {
  function_name = "cloudfront-edge"
  role          = aws_iam_role.edge.arn
  handler       = "main"

  # s3_bucket = aws_s3_bucket.invalidator-artifacts
  # s3_key    = "latest.zip"
  filename = "latest.zip"

  runtime = "go1.x"

  # depends_on = [
  #   aws_s3_bucket.invalidator-artifacts
  # ]
}


resource "aws_iam_role" "edge" {
  name               = "cloudfront-edge"
  assume_role_policy = data.aws_iam_policy_document.edge.json
}

data "aws_iam_policy_document" "edge" {
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


resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.edge.name
  policy_arn = aws_iam_policy.edge.arn
}

resource "aws_iam_policy" "edge" {
  name        = "LambdaEdgeLogging"
  description = "Enable CloudFront Edge lambda function logging."

  policy = data.aws_iam_policy_document.edge-logging.json
}


data "aws_iam_policy_document" "edge-logging" {

  statement {
    sid = "Logging"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:%s:logs:*::log-group:/aws/lambda/*:*:*"
    ]
  }

}

