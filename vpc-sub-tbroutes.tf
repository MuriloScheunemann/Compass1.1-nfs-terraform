# VPC
resource "aws_vpc" "vpc-efs" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true #Para poder montar o EFS
  tags = {
    "Name" = "vpc-efs"
  }
}

# Subnet
resource "aws_subnet" "subnet-efs" {
  vpc_id            = aws_vpc.vpc-efs.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/24"
  tags = {
    "Name" = "subnet-efs-1a"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-efs.id

  tags = {
    Name = "IGW"
  }
}

# Tabelas de Rotamento
resource "aws_route_table" "routes" {
  vpc_id = aws_vpc.vpc-efs.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RouteTable"
  }
}

# Associa a tabela de roteamento como 'main route' da VPC (para conectar a subnet ao IG)
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc-efs.id
  route_table_id = aws_route_table.routes.id
}
