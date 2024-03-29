

resource "aws_s3_bucket" "artifacts" {
  for_each = local.static_sites

  bucket = "${replace(each.value.hostname, ".", "-")}--artifacts"
  acl    = "private"

  versioning {
    enabled = false
  }
}
