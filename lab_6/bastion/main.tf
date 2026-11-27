terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-w9e85"
    key            = "global/s3/student_12_5/bastion.tfstate"
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

# SG RDS créé par le student A
data "aws_security_group" "rds" {
  filter {
    name   = "group-name"
    values = ["${local.prefix}_rds"]
  }
}

# Paramètres SSM du student A. Le password est volontairement exclu : le bastion le lira
# lui-même via son rôle IAM, pour qu'il n'atterrisse pas dans le state.
data "aws_ssm_parameter" "db" {
  for_each = toset(["endpoint", "name", "port", "username"])

  name = "${local.ssm_prefix}/${each.key}"
}

resource "aws_security_group" "bastion" {
  name        = "${local.prefix}_bastion"
  description = "SSH from my IP only"
  vpc_id      = data.aws_vpc.lab.id

  tags = {
    Name = "${local.prefix}_bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
