output "env_bucket_arn" {
  value = aws_s3_bucket.env_files.arn
}

output "app_storage_bucket_arn" {
  value = aws_s3_bucket.app_storage.arn
}