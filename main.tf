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
  extra_tags = {
    Role = "master-node"
  }
}

module "worker1" {
  source             = "./modules/ec2"
  enabled            = true
  name               = "k8s-worker-1"
  ami_id             = "ami-020cba7c55df1f615"
  instance_type      = "t3.micro"
  subnet_id          = aws_subnet.public[1].id
  security_group_ids = [aws_security_group.k8s.id]
  key_name           = "test_key_demo"
  user_data_path     = "${path.module}/user_data/worker.sh"
  extra_tags = {
    Role = "worker-node"
  }
}

module "worker2" {
  source             = "./modules/ec2"
  enabled            = true
  name               = "k8s-worker-2"
  ami_id             = "ami-020cba7c55df1f615"
  instance_type      = "t3.micro"
  subnet_id          = aws_subnet.public[2].id
  security_group_ids = [aws_security_group.k8s.id]
  key_name           = "test_key_demo"
  user_data_path     = "${path.module}/user_data/worker.sh"
  extra_tags = {
    Role = "worker-node"
  }
}

module "master_node_iam" {
  source      = "./modules/iam"
  role_name   = "master-node-role"
  policy_name = "MasterNodePolicy"
  policy_file = "${path.module}/iam_policies/master_node_policy.json"
}

module "worker_node_iam" {
  source      = "./modules/iam"
  role_name   = "worker-node-role"
  policy_name = "WorkerNodePolicy"
  policy_file = "${path.module}/iam_policies/worker_node_policy.json"
}

module "lambda_trigger_iam" {
  source          = "./modules/iam"
  role_name       = "lambda-trigger-role"
  policy_name     = "LambdaTriggerPolicy"
  policy_file     = "${path.module}/iam_policies/lambda_trigger_policy.json"
  trusted_service = "lambda.amazonaws.com"
}

module "bootstrap_bucket" {
  source      = "./modules/s3"
  bucket_name = "k8s-bootstrap-artifacts"
  environment = "dev"
}

module "lambda_trigger" {
  source          = "./modules/lambda_trigger"
  lambda_role_arn = module.lambda_trigger_iam.role_arn
  s3_bucket_name  = "k8s-bootstrap-artifacts"
}
