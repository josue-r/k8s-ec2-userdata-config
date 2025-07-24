resource "aws_s3_bucket" "worker_node_token" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "worker_node_token_access" {
  bucket = aws_s3_bucket.worker_node_token.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

