provider "aws" {
  region = "ap-northeast-1"
  profile = "default"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "test"
  }
}

resource "aws_subnet" "public_0" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "public_1" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_0" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_0.id
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_1.id
}

resource "aws_subnet" "private_0" {
  cidr_block = "10.0.64.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_1" {
  cidr_block = "10.0.65.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "private_0" {
  route_table_id = aws_route_table.private_0.id
  subnet_id = aws_subnet.private_0.id
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private_1.id
  subnet_id = aws_subnet.private_1.id
}

resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.private_0.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.private_1.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_0" {
  route_table_id = aws_route_table.private_0.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private_1.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

//resource "aws_security_group" "sg" {
//  name = "sg"
//  vpc_id = aws_vpc.vpc.id
//}
//
//resource "aws_security_group_rule" "ingress" {
//  from_port = 80
//  protocol = "tcp"
//  security_group_id = aws_security_group.sg.id
//  to_port = 80
//  type = "ingress"
//  cidr_blocks = ["0.0.0.0/0"]
//}
//
//resource "aws_security_group_rule" "egress" {
//  from_port = 0
//  protocol = "-1"
//  security_group_id = aws_security_group.sg.id
//  to_port = 0
//  type = "egress"
//  cidr_blocks = ["0.0.0.0/0"]
//}

module "sg" {
  source = "../security_group"
  name = "main"
  vpc_id = aws_vpc.vpc.id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}