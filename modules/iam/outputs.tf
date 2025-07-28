output "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  value       = aws_iam_instance_profile.master_node_ec2_instance_profile.name
}

output "role_name" {
  value = aws_iam_role.master_node_ec2.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.master_node_ec2.arn
}