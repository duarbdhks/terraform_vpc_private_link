#### VPC ####
resource "aws_vpc" "dev" {
  cidr_block           = "172.16.0.0/16"
  instance_tenancy     = var.instanceTenancy
  enable_dns_hostnames = var.dnsHostNames
  enable_dns_support   = var.dnsSupport
  tags = {
    Name = "dev-vpc"
  }
}

#### 서브넷 ####
/*
AZ: ap-northeast-2a
    public  subnet: 172.16.1.0/24
    private subnet: 172.16.101.0/24
AZ: ap-northeast-2c
    public  subnet: 172.16.2.0/24
    private subnet: 172.16.102.0/24
*/
resource "aws_subnet" "public_2a" {
  cidr_block              = "172.16.1.0/24"
  vpc_id                  = aws_vpc.dev.id
  map_public_ip_on_launch = true
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "public-2a"
  }
}

resource "aws_subnet" "private_2a" {
  cidr_block              = "172.16.101.0/24"
  vpc_id                  = aws_vpc.dev.id
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "private-2a"
  }
}

resource "aws_subnet" "public_2c" {
  cidr_block              = "172.16.2.0/24"
  vpc_id                  = aws_vpc.dev.id
  map_public_ip_on_launch = true
  availability_zone       = var.availabilityZoneC
  tags = {
    Name = "public-2c"
  }
}

resource "aws_subnet" "private_2c" {
  cidr_block              = "172.16.102.0/24"
  vpc_id                  = aws_vpc.dev.id
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZoneC
  tags = {
    Name = "private-2c"
  }
}

#### Internet Gateway ####
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-IGW"
  }
}

#### EIP ####
resource "aws_eip" "nat_dev_2a" {
  vpc = true
}

resource "aws_eip" "nat_dev_2c" {
  vpc = true
}

#### NAT Gateway ####
resource "aws_nat_gateway" "dev_2a" {
  allocation_id = aws_eip.nat_dev_2a.id
  subnet_id     = aws_subnet.public_2a.id
}

resource "aws_nat_gateway" "dev_2c" {
  allocation_id = aws_eip.nat_dev_2c.id
  subnet_id     = aws_subnet.public_2c.id
}

#### Route Table ####
resource "aws_route_table" "dev_public" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags = {
    Name = "dev-public"
  }
}

resource "aws_route_table_association" "dev_public_2a" {
  subnet_id      = aws_subnet.public_2a.id
  route_table_id = aws_route_table.dev_public.id
}

resource "aws_route_table_association" "dev_public_2c" {
  subnet_id      = aws_subnet.public_2c.id
  route_table_id = aws_route_table.dev_public.id
}

# dev private 2a
resource "aws_route_table" "dev_private_2a" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_2a.id
  }
  tags = {
    Name = "dev-private-2a"
  }
}

resource "aws_route_table_association" "dev_private_2a" {
  route_table_id = aws_route_table.dev_private_2a.id
  subnet_id      = aws_subnet.private_2a.id
}

# dev private 2c
resource "aws_route_table" "dev_private_2c" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_2c.id
  }
  tags = {
    Name = "dev-private-2c"
  }
}

resource "aws_route_table_association" "dev_private_2c" {
  route_table_id = aws_route_table.dev_private_2c.id
  subnet_id      = aws_subnet.private_2c.id
}

#### Network ACL ####
resource "aws_default_network_acl" "dev_default" {
  default_network_acl_id = aws_vpc.dev.default_network_acl_id
  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = -1
    rule_no    = 100
    from_port  = 0
    to_port    = 0
  }
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = -1
    rule_no    = 100
    from_port  = 0
    to_port    = 0
  }
  subnet_ids = [
    aws_subnet.public_2a.id,
    aws_subnet.public_2c.id,
    aws_subnet.private_2a.id,
    aws_subnet.private_2c.id
  ]
  tags = {
    Name = "dev-default"
  }
}

#### Security Group ####
resource "aws_security_group" "dev_security_group_private_2a" {
  vpc_id      = aws_vpc.dev.id
  name        = "dev security group private 2a"
  description = "dev security group private 2a"
  ingress {
    security_groups = [aws_security_group.dev_security_group_public_2a.id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "dev-security-group-private"
  }
}

resource "aws_security_group" "dev_security_group_public_2a" {
  vpc_id      = aws_vpc.dev.id
  name        = "dev security group public 2a"
  description = "dev security group public 2a"
  ingress {
    cidr_blocks = ["218.147.172.17/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "dev-security-group-private"
  }
}

resource "aws_security_group" "dev_security_group_private_2c" {
  vpc_id      = aws_vpc.dev.id
  name        = "dev security group private 2c"
  description = "dev security group private 2C"
  ingress {
    security_groups = [aws_security_group.dev_security_group_public_2c.id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "dev-security-group-private"
  }
}

resource "aws_security_group" "dev_security_group_public_2c" {
  vpc_id      = aws_vpc.dev.id
  name        = "dev security group public 2c"
  description = "dev security group public 2c"
  ingress {
    cidr_blocks = ["218.147.172.17/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "dev-security-group-private"
  }
}

#### s3 bucket ####
resource "aws_s3_bucket" "tfendpoint" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "dev-endpoint-bucket"
    Environment = "vpc-endpoint-test"
  }
}