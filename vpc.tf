data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "k8s" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "k8s-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "k8s" {
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s-igw"
  }
}

# Create Route Table
resource "aws_route_table" "k8s" {
  vpc_id = aws_vpc.k8s.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s.id
  }

  tags = {
    Name = "k8s-public-rt"
  }
}

# Create 3 public subnets in different AZs
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = cidrsubnet(aws_vpc.k8s.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-public-subnet-${count.index + 1}"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.k8s.id
}