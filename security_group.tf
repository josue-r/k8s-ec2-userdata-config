resource "aws_security_group" "k8s" {
  name        = "k8s-cluster-sg"
  description = "Allow SSH and Kubernetes API from the public internet"
  vpc_id      = aws_vpc.k8s.id  # Use your existing VPC

  # Allow SSH (port 22) from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Kubernetes API (port 6443) from anywhere
  ingress {
    description = "Kubernetes API access"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-cluster-sg"
  }
}
