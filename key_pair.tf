resource "aws_key_pair" "k8s" {
  key_name   = "k8s-key"
  public_key = file("~/.ssh/k8s-key.pub")
}