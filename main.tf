provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ______________________________________________________________________________
# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.main_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Main_VPC"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main IGW"
  }
}
# Create Route Table; link to the Enternet Gateway
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name  = "Route Table"
    Owner = "Maksym Manovytskyi"
  }
}
# Create Route Table association for Application subnets
resource "aws_route_table_association" "table1" {
  subnet_id      = element(aws_subnet.app_subnet.*.id, count.index)
  count          = length(var.app_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}
# Create Route Table association for ALB subnets
resource "aws_route_table_association" "table2" {
  subnet_id      = element(aws_subnet.alb_subnet.*.id, count.index)
  count          = length(var.alb_subnet_cidr_block)
  route_table_id = aws_route_table.route_table.id
}
# Create subnets for application: ECS task
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.app_subnet_cidr_block)
  cidr_block        = element(var.app_subnet_cidr_block, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name  = "APP subnet"
    Owner = "Maksym Manovytskyi"
  }
}
# Create subnets for the load balancer
resource "aws_subnet" "alb_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.alb_subnet_cidr_block)
  cidr_block        = element(var.alb_subnet_cidr_block, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name  = "ALB subnet"
    Owner = "Maksym Manovytskyi"
  }
}
# Create subnets for database
resource "aws_subnet" "db_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.db_subnet_cidr_block)
  cidr_block        = element(var.db_subnet_cidr_block, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name  = "DB subnet"
    Owner = "Maksym Manovytskyi"
  }
}
# Create Load Balancer
resource "aws_lb" "alb" {
  name               = "App-server"
  load_balancer_type = "application"
  subnets            = aws_subnet.alb_subnet.*.id
  tags = {
    Owner = "Maksym Manovytskyi"
    Name  = "Test ALB for 3 subnets"
  }
}
# Create a subnet group for RDS Database
resource "aws_db_subnet_group" "db_group" {
  name       = "main"
  subnet_ids = aws_subnet.alb_subnet.*.id
  tags = {
    Name  = "My DB subnet group"
    Owner = "Maksym Manovytskyi"
  }
}
# Create an RDS DB
resource "aws_db_instance" "db" {
  allocated_storage      = var.alloc_storage
  storage_type           = var.stor_type
  engine                 = var.db_engine
  engine_version         = var.engine_ver
  instance_class         = var.db_instance
  name                   = var.db_name
  port                   = var.db_port
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Name  = "Test MySQL RDS"
    Owner = "Maksym Manovytskyi"
  }
}
# Specify security group for RDS DB
resource "aws_security_group" "db_sg" {
  name        = "vpc_db"
  description = "Allow incoming database connections"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidr_block
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
