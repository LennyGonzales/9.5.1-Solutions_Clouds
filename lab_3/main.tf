terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_key_pair" "this" {
  key_name   = "lab3-student_12-"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "this" {
  name        = "lab3-sg"
  description = "Allow SSH"
  vpc_id      = var.vpc_id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lab3-sg"
  }
}

resource "aws_instance" "this" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name = aws_key_pair.this.key_name
  associate_public_ip_address = true
  tags = {
    Name = "lab3-instance"
  }
}