variable "lambda_role_arn" {
  type        = string
  description = "IAM Role ARN for Lambda"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket that contains the join command file"
}

variable "s3_key_filter" {
  type    = string
  default = "join-command.txt"
}
