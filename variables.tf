variable "environment" {
  type        = string
  description = "Name of environment"
}

variable "project" {
  type        = string
  description = "Name of project"
}

variable "aws_access_key" {
  type        = string
  description = "AWS programmatic access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS programmatic secret key"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "static_sites" {
  type = list(object({
    hostname = string
    aliases  = list(string)
  }))

  description = "List of static sites. The following are provisioned: S3 bucket, Cloudfront distribution, Lambda Edge function, ACM entry."
}
