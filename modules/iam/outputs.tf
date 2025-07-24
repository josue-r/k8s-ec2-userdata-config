output "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  value       = aws_iam_instance_profile.master_node_ec2_instance_profile.name
}