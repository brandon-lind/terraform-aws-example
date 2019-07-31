# -----------------------------------------------------------------------------
# Outputs: S3
# -----------------------------------------------------------------------------

output "aws_s3_bucket___bucket" {
  value = aws_s3_bucket._.bucket
}

output "aws_s3_bucket_logs_bucket" {
  value = aws_s3_bucket.logs.bucket
}

# -----------------------------------------------------------------------------
# Outputs: Cloudfront
# -----------------------------------------------------------------------------

output "aws_cloudfront_distribution___domain_name" {
  value = aws_cloudfront_distribution._.domain_name
}
