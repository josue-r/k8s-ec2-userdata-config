resource "aws_instance" "cluster_ec2" {
  count                  = var.enabled ? 1 : 0
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  user_data              = file(var.user_data_path)
  iam_instance_profile   = var.iam_instance_profile

  tags = merge({
    Name = var.name
  }, var.extra_tags)
}
