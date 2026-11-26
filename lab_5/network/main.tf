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

data "aws_internet_gateway" "lab" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.lab.id]
  }
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.lab.id
  }

  tags = {
    Name = "${local.prefix}_public_rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    a = aws_subnet.public_a.id
    b = aws_subnet.public_b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
  name        = "${local.prefix}_public"
  description = "HTTP/HTTPS from internet"
  vpc_id      = data.aws_vpc.lab.id

  tags = {
    Name = "${local.prefix}_public"
  }
}

resource "aws_security_group" "internal" {
  name        = "${local.prefix}_internal"
  description = "HTTP/HTTPS from the public security group only"
  vpc_id      = data.aws_vpc.lab.id

  tags = {
    Name = "${local.prefix}_internal"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
}

resource "aws_vpc_security_group_ingress_rule" "internal" {
  for_each = toset(["80", "443"])

  security_group_id            = aws_security_group.internal.id
  referenced_security_group_id = aws_security_group.public.id
  ip_protocol                  = "tcp"
  from_port                    = tonumber(each.key)
  to_port                      = tonumber(each.key)
}

resource "aws_vpc_security_group_egress_rule" "all" {
  for_each = {
    public   = aws_security_group.public.id
    internal = aws_security_group.internal.id
  }

  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

module "alb" {
  source = "./modules/alb"

  name               = local.prefix
  vpc_id             = data.aws_vpc.lab.id
  subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_group_ids = [aws_security_group.public.id]
}
