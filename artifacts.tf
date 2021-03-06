
# resource "aws_s3_bucket" "artifacts" {
#   bucket = "mombo-artifacts"
#   acl    = "private"

#   tags = {
#     Name        = var.project
#     Environment = var.environment
#   }

#   versioning {
#     enabled = true
#   }
# }
