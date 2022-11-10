resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "test"
  }
}

locals {
  public_subnet_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnet_cidrs = ["172.16.3.0/24", "172.16.4.0/24"]
  az                   = ["ap-south-1a", "ap-south-1b"]
}

resource "aws_subnet" "public_subnets" {
  count                   = length(local.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(local.az, count.index)
  cidr_block              = element(local.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "test-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "test-internet-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "test-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(local.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.route_table.id
}

# resource "aws_subnet" "private_subnets" {
#   count             = length(local.private_subnet_cidrs)
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = element(local.private_subnet_cidrs, count.index)
#   availability_zone = element(local.az, count.index)
#   tags = {
#     Name = "test-private-subnet-${count.index}"
#   }
# }

resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["124.40.244.136/32"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["124.40.244.136/32"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow"
  }
}

# resource "aws_security_group" "lamda_sg" {
#   name        = "lambda-sg"
#   description = "Allow inbound traffic"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description = "https from VPC"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["172.16.0.0/16"]
#     # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "lambda-sg"
#   }
# }

# resource "aws_vpc_endpoint" "vpc_endpoint" {
#   service_name        = "com.amazonaws.ap-south-1.execute-api"
#   vpc_endpoint_type   = "Interface"
#   vpc_id              = aws_vpc.vpc.id
#   security_group_ids  = [aws_security_group.lamda_sg.id]
#   subnet_ids          = [aws_subnet.private_subnets[0].id]
#   private_dns_enabled = true
# }

# # nat gateway

# resource "aws_eip" "eip" {
#   vpc      = true
# }

# resource "aws_nat_gateway" "nat" {
#   depends_on = [
#     aws_eip.eip,
#     aws_internet_gateway.internet_gateway
#   ]
#   allocation_id = aws_eip.eip.id
#   subnet_id = aws_subnet.public_subnets[0].id
# }

# resource "aws_route_table" "nat_route" {
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }
# }

# resource "aws_route_table_association" "nat_route_association" {
#   subnet_id = aws_subnet.private_subnets[0].id
#   route_table_id = aws_route_table.nat_route.id
# }