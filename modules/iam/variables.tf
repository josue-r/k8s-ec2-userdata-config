variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "inline_policy" {
  type        = string
  description = "JSON encoded IAM policy"
}
