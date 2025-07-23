output "vpc_id" {
  value = aws_vpc.k8s.id
}

output "subnet_ids" {
  value = aws_subnet.public[*].id
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}