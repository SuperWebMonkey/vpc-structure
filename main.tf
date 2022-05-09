/* 
    Create a vpc with 3 public subnets and 3 private subnets
    Create 2 route tables
    Create a nat gateway
*/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# vpc
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "chrise-tf-vpc"
    }
}

# public subnets
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"

    tags = {
        Name = "public--tf-subnet-1"
    }
}

resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"

    tags = {
        Name = "public-tf-subnet-2"
    }
}

resource "aws_subnet" "subnet-3" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1c"

    tags = {
        Name = "public-tf-subnet-3"
    }
}

#private subnets
resource "aws_subnet" "subnet-4" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.8.0/24"
    map_public_ip_on_launch = false
    availability_zone = "us-east-1a"

    tags = {
        Name = "chris-tf-private-subnet"
    }
}

resource "aws_subnet" "subnet-5" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.16.0/24"
    map_public_ip_on_launch = false
    availability_zone = "us-east-1b"

    tags = {
        Name = "chris-tf-private-subnet-2"
    }
}

resource "aws_subnet" "subnet-6" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.32.0/24"
    map_public_ip_on_launch = false
    availability_zone = "us-east-1c"

    tags = {
        Name = "chris-tf-private-subnet-3"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name  = "chris-tf-igw"
    Enviornment = "chris-environment"
  }
}

# Elastic IP 
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.subnet-1.id
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "chris-tf-nat-gw"
  }
}

# Public Route table
resource "aws_route_table" "pub-rt" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0" # all IPs
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "chris-tf-public-table"
    }
}

# Private Route Table
resource "aws_route_table" "priv-rt" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name = "chris-tf-private-table"
    }
}

# Public route table association
resource "aws_route_table_association" "pub-a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pub-b" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pub-c" {
  subnet_id      = aws_subnet.subnet-3.id
  route_table_id = aws_route_table.pub-rt.id
}

# Private route table association 
resource "aws_route_table_association" "priv-a" {
  subnet_id      = aws_subnet.subnet-4.id
  route_table_id = aws_route_table.priv-rt.id
}

resource "aws_route_table_association" "priv-b" {
  subnet_id      = aws_subnet.subnet-5.id
  route_table_id = aws_route_table.priv-rt.id
}

resource "aws_route_table_association" "priv-c" {
  subnet_id      = aws_subnet.subnet-6.id
  route_table_id = aws_route_table.priv-rt.id
}
