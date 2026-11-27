# À communiquer au student Y pour scoper la policy IAM du rôle EC2
output "bucket_name" {
  value = aws_s3_bucket.shared.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.shared.arn
}
