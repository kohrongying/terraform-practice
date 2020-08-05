variable "resource_tag" {}
variable "environment" {}
variable "cidr_blocks" {
  type        = map
  default = {
    "public" = ["10.0.0.0/27", "10.0.0.32/27"]
    "private" = ["10.0.0.128/27", "10.0.0.160/27"]
  }
  description = "Map of subnet CIDR blocks"
}
variable "availability_zones" {
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
  description = "List of availability zones"
}
variable "vpc_cidr_block" {
  default = "10.0.0.0/24"
}

## VPC, Subnets, RT and IGW
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_tag} - ${var.environment}"
  }
}

## Public subnets, RT, IGW
resource "aws_subnet" "public" {
  count = length(var.cidr_blocks["public"])

  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_blocks["public"][count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public ${count.index}"
    Type = "public"
  }
}

resource "aws_security_group" "http" {
  name = "allow web"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80 
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# should not be used for production
# resource "aws_security_group" "ssh" {
#   name = "allow ssh"
#   vpc_id = aws_vpc.main.id
#   ingress {
#     from_port = 22
#     to_port = 22
#     cidr_blocks = ["0.0.0.0/0"]
#     protocol = "tcp"
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.cidr_blocks["public"])

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_subnet" "private" {
  count = length(var.cidr_blocks["private"])

  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_blocks["private"][count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private ${count.index}"
    Type = "private"
  }
}

resource "aws_route_table" "private" {
  count = length(var.cidr_blocks["private"])
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private" {
  count = length(var.cidr_blocks["private"])

  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}


resource "aws_route_table_association" "private" {
  count = length(var.cidr_blocks["private"])

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  depends_on = [aws_internet_gateway.main]
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}