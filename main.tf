module "master" {
  source               = "./modules/ec2"
  enabled              = true
  name                 = "k8s-master"
  ami_id               = "ami-020cba7c55df1f615"
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.public[0].id
  security_group_ids   = [aws_security_group.k8s.id]
  key_name             = "test_key_demo"
  user_data_path       = "${path.module}/user_data/master.sh"
  iam_instance_profile = module.master_node_iam.iam_instance_profile_name
}

module "worker1" {
  source             = "./modules/ec2"
  enabled            = false
  name               = "k8s-worker-1"
  ami_id             = "subnet-84c1fbaa"
  instance_type      = "t3.micro"
  subnet_id          = aws_subnet.public[1].id
  security_group_ids = [aws_security_group.k8s.id]
  key_name           = "test_key_demo"
  user_data_path     = "${path.module}/user_data/worker.sh"
}

module "worker2" {
  source             = "./modules/ec2"
  enabled            = false
  name               = "k8s-worker-2"
  ami_id             = "ami-020cba7c55df1f615"
  instance_type      = "t3.micro"
  subnet_id          = aws_subnet.public[2].id
  security_group_ids = [aws_security_group.k8s.id]
  key_name           = "test_key_demo"
  user_data_path     = "${path.module}/user_data/worker.sh"
}

module "master_node_iam" {
  source    = "./modules/iam"
  role_name = "master-node-role"
  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:PutObject"],
      Resource = "arn:aws:s3:::k8s-bootstrap-artifacts/*"
    }]
  })
}

module "bootstrap_bucket" {
  source      = "./modules/s3"
  bucket_name = "k8s-bootstrap-artifacts"
  environment = "dev"
}