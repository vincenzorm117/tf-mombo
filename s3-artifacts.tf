

resource "aws_s3_bucket" "artifacts" {
  for_each = local.static_sites

  bucket = "${replace(each.value.hostname, ".", "-")}--artifacts"
  acl    = "private"


  # policy = data.aws_iam_policy_document.bucket_policy.json
  versioning {
    enabled = false
  }
}
