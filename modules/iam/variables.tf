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
