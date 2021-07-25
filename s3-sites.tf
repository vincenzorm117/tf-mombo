


resource "aws_s3_bucket" "site" {
  for_each = local.static_sites
  bucket   = "${replace(each.value.hostname, ".", "-")}--site"
  acl      = "private"


  website {
    index_document = "index.html"
    error_document = "index.html"
    routing_rules  = ""
  }

  versioning {
    enabled = false
  }
}

data "aws_iam_policy_document" "site_bucket_policy" {
  for_each = local.static_sites
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.site[each.value.hostname].arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.site[each.value.hostname].iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  for_each = local.static_sites

  bucket = aws_s3_bucket.site[each.value.hostname].id
  policy = data.aws_iam_policy_document.site_bucket_policy[each.value.hostname].json
}
