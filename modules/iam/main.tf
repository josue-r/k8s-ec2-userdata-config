resource "aws_iam_role" "master_node_ec2" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "master_node_ec2_policy" {
  name   = var.policy_name
  role   = aws_iam_role.master_node_ec2.id
  policy = file(var.policy_file)
}

resource "aws_iam_instance_profile" "master_node_ec2_instance_profile" {
  name = "${var.role_name}-profile"
  role = aws_iam_role.master_node_ec2.name
}
