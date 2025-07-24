output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.worker_node_token.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.worker_node_token.arn
}
