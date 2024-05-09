resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block[terraform.workspace]
  tags = {
    IaC = true
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.vpc_cidr_block_a[terraform.workspace]
  availability_zone = "us-east-1a"
  tags = {
    IaC = true
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.vpc_cidr_block_b[terraform.workspace]
  availability_zone = "us-east-1b"
  tags = {
    IaC = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    IaC = true
  }
}