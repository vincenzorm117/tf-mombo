variable "refer_secret" {
  type        = string
  description = "A secret string to authenticate CF requests to S3"
  default     = "123-VERY-SECRET-123"
}

variable "allowed_ips" {
  type        = list(string)
  description = "A list of IPs that can access the S3 bucket directly"
  default     = []
}

variable "aliases" {
  type        = list(string)
  description = "Any other domain aliases to add to the CloudFront distribution"
  default     = []
}


variable "hostname" {
  type        = string
  description = "Hostname for site"
}

variable "bucketName" {
  type        = string
  description = "Name for s3 bucket"
}


variable "environment" {
  type        = string
  description = "Name of environment"
}

variable "project" {
  type        = string
  description = "Name of project"
}

variable "lambda_edges" {
  default = []

  type = list(object({
    event_type = string
    lambda_arn = string #"${lambda.arn}:${lambda.version}"
  }))
}

variable "web_acl_id" {
  type        = string
  description = "WAF Web ACL ID to attach to the CloudFront distribution, optional"
  default     = ""
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

variable "s3_lambda_artifacts" {
  type        = string
  description = "Name for S3 bucket containing API gateway lambda artifacts."
}

variable "static_sites" {
  type = list(object({
    hostname = string
  }))

  description = "List of static sites. The following are provisioned: S3 bucket, Cloudfront distribution, Lambda Edge function, ACM entry."
}

variable "apis" {
  type = list(object({
    hostname = string
    endpoints = list(object({
      name   = string
      method = string
    }))
  }))

  description = "This is the list of APIs for which an API gateway is setup along with lambda functions for each endpoint and an API Gateway custom DNS name."
}
