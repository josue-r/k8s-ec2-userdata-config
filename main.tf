module "master" {
  source             = "./modules/ec2"
  enabled            = false
  name               = "k8s-master"
  ami_id             = "ami-020cba7c55df1f615"
  instance_type      = "t3.micro"
  subnet_id          = aws_subnet.public[0].id
  security_group_ids = [aws_security_group.k8s.id]
  key_name           = "test_key_demo"
  user_data_path     = "${path.module}/user_data/master.sh"
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
