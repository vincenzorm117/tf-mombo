


resource "aws_s3_bucket" "mombo-deploy" {
  bucket = var.bucketName
  acl    = "private"

  tags = {
    Name        = var.project
    Environment = var.environment
  }

  policy = data.aws_iam_policy_document.bucket_policy.json

  website {
    index_document = "index.html"
    error_document = "index.html"
    routing_rules = ""
  }

  versioning {
    enabled = true
  }
}



data "aws_iam_policy_document" "bucket_policy" {

  statement {
    sid = "AllowedIPReadAccess"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucketName}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = var.allowed_ips
    }

    principals {
      type = "*"
      identifiers = [
      "*"]
    }
  }

  statement {
    sid = "AllowCFOriginAccess"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucketName}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"

      values = [
        var.refer_secret,
      ]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
