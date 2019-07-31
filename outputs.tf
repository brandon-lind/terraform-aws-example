# -----------------------------------------------------------------------------
# Providers
# -----------------------------------------------------------------------------

output "aws_account_id" {
  value = data.aws_caller_identity._.account_id
}

output "aws_region" {
  value = var.region
}

output "stage" {
  value = var.stage
}

# -----------------------------------------------------------------------------
# Outputs: Web (S3, Cloudfront, etc.)
# -----------------------------------------------------------------------------

#output "aws_s3_bucket___bucket" {
#  value = module.web.aws_s3_bucket._.bucket
#}

#output "aws_s3_bucket_logs_bucket" {
#  value = module.web.aws_s3_bucket.logs.bucket
#}

#output "aws_cloudfront_distribution___domain_name" {
#  value = module.web.aws_cloudfront_distribution._.domain_name
#}

