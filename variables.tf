# Set up region
variable "region" {
  description = "Choose the required AWS region"
  default     = "us-east-1"
}
# VPC and subnets variables
variable "main_vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "app_subnet_cidr_block" {
  type    = list(any)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "alb_subnet_cidr_block" {
  type    = list(any)
  default = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24"]
}

variable "db_subnet_cidr_block" {
  type    = list(any)
  default = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}
# Password set up for db connection: required for db creation; asked for during apply
variable "db_password" {
  type = string
}
# Details about the database
variable "alloc_storage" {
  default = 20
}
variable "stor_type" {
  default = "gp2"
}
variable "db_engine" {
  default = "mysql"
}
variable "engine_ver" {
  default = "5.7"
}
variable "db_instance" {
  default = "db.t2.micro"
}
variable "db_name" {
  default = "new_db"
}
variable "db_user" {
  default = "new_user"
}
variable "db_port" {
  default = "3306"
}
