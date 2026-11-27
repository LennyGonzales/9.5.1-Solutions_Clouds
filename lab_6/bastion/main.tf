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

data "aws_caller_identity" "current" {}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}_Public_a"]
  }
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Le rôle IAM donne au bastion le droit de lire les paramètres SSM de A, et rien d'autre
resource "aws_iam_role" "bastion" {
  name = "${local.prefix}_bastion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "read_db_params" {
  name = "read_db_params"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
      Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_prefix}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}_bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_key_pair" "bastion" {
  key_name   = "${local.prefix}_bastion"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  key_name               = aws_key_pair.bastion.key_name

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    amazon-linux-extras install postgresql14 -y

    # Les identifiants sont lus dans SSM à chaque exécution : le mot de passe n'est jamais écrit sur le disque
    cat > /home/ec2-user/connect-db.sh <<'SCRIPT'
    #!/bin/bash
    p() { aws ssm get-parameter --region ${var.region} --name ${local.ssm_prefix}/$1 --with-decryption --query Parameter.Value --output text; }
    PGPASSWORD=$(p password) exec psql -h $(p endpoint) -p $(p port) -U $(p username) -d $(p name)
    SCRIPT
    chown ec2-user:ec2-user /home/ec2-user/connect-db.sh
    chmod 700 /home/ec2-user/connect-db.sh
  EOF

  tags = {
    Name = "${local.prefix}_bastion"
  }
}
