terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
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
    Name = "${var.name}-sg"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_subnet" "subnet" {
  vpc_id = var.vpc_id
  availability_zone = var.availability_zone
}

resource "aws_instance" "this" {
  ami = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name = aws_key_pair.this.key_name
  associate_public_ip_address = true
  tags = {
    Name = var.name
  }
}