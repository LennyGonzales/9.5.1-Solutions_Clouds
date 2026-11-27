terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-w9e85"
    key            = "global/s3/student_12_5/network_rds.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

locals {
  prefix     = "student_${var.student_x}_${var.student_y}"
  ssm_prefix = "/lab6/db/${local.prefix}"
}

data "aws_vpc" "lab" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Subnet privé créé au lab 5 (eu-west-3a)
data "aws_subnet" "private_a" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}_Private"]
  }
}

# Un DB subnet group exige des subnets dans au moins 2 AZ
resource "aws_subnet" "private_b" {
  vpc_id            = data.aws_vpc.lab.id
  cidr_block        = cidrsubnet(data.aws_vpc.lab.cidr_block, 8, 100 + var.student_x)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${local.prefix}_Private_b"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${replace(local.prefix, "_", "-")}-rds"
  subnet_ids = [data.aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${local.prefix}_rds"
  }
}

resource "aws_security_group" "rds" {
  name        = "${local.prefix}_rds"
  description = "PostgreSQL from the bastion security group only"
  vpc_id      = data.aws_vpc.lab.id

  tags = {
    Name = "${local.prefix}_rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_bastion" {
  count = var.bastion_sg_id == null ? 0 : 1

  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.bastion_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "random_password" "db" {
  length           = 24
  override_special = "-_"
}

resource "aws_db_instance" "postgres" {
  identifier        = "${replace(local.prefix, "_", "-")}-labdb"
  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  skip_final_snapshot = true

  tags = {
    Name = "${local.prefix}_labdb"
  }
}

resource "aws_ssm_parameter" "db" {
  for_each = {
    username = aws_db_instance.postgres.username
    name     = aws_db_instance.postgres.db_name
    endpoint = aws_db_instance.postgres.address
    port     = tostring(aws_db_instance.postgres.port)
  }

  name  = "${local.ssm_prefix}/${each.key}"
  type  = "String"
  value = each.value
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm_prefix}/password"
  type  = "SecureString"
  value = random_password.db.result
}
