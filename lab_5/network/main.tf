terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-w9e85"
    key            = "global/s3/student_12_5/network.tfstate"
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
  prefix = "student_${var.student_x}_${var.student_y}"
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

resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.lab.id
  cidr_block        = cidrsubnet(data.aws_vpc.lab.cidr_block, 8, var.student_x)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${local.prefix}_Private"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = data.aws_vpc.lab.id
  cidr_block              = cidrsubnet(data.aws_vpc.lab.cidr_block, 8, var.student_y)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.prefix}_Public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = data.aws_vpc.lab.id
  cidr_block              = cidrsubnet(data.aws_vpc.lab.cidr_block, 8, 100 + var.student_y)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.prefix}_Public_b"
  }
}
