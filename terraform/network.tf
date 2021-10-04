provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    "Name" = "satoshi_abe_example"
  }
}

resource "aws_subnet" "public_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  
  tags = {
    "Name" = "satoshi_abe_public_0"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  
  tags = {
    "Name" = "satoshi_abe_public_1"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  
  tags = {
    "Name" = "satoshi_abe_example"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
  
  tags = {
    "Name" = "satoshi_abe_example"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_0" {
  subnet_id = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [aws_internet_gateway.example]  
  tags = {
    "Name" = "satoshi_abe_example_0"
  }
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [aws_internet_gateway.example]  
  tags = {
    "Name" = "satoshi_abe_example_1"
  }
}

resource "aws_nat_gateway" "example_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public_0.id
  depends_on = [
    aws_internet_gateway.example
  ]

  tags = {
    "Name" = "satoshi_abe_example_0"
  }
}

resource "aws_nat_gateway" "example_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [
    aws_internet_gateway.example
  ]

  tags = {
    "Name" = "satoshi_abe_example_1"
  }
}

resource "aws_security_group" "example" {
  name        = "satoshi_abe_example"
  vpc_id      = aws_vpc.example.id

  tags = {
    Name = "satoshi_abe_example"
  }
}

resource "aws_security_group_rule" "ingress" {
  type = "ingress"
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.example.id
}

resource "aws_security_group_rule" "ingress_container" {
  type = "ingress"
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 8000
  to_port = 8000
  protocol = "tcp"
  security_group_id = aws_security_group.example.id
}


resource "aws_security_group_rule" "egress" {
  type = "egress"
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.example.id
}
