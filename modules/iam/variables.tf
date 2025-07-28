variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "policy_file" {
  type        = string
  description = "Path to the IAM policy JSON file"
}

variable "policy_name" {
  type        = string
  description = "Policy name"
}

variable "trusted_service" {
  type        = string
  description = "The AWS service that can assume this role"
  default     = "ec2.amazonaws.com" # default for EC2
}