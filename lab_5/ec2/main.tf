terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-w9e85"
    key            = "global/s3/student_12_5/ec2.tfstate"
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
  apps   = toset(["nginx", "tomcat"])
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_subnet" "private" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}_Private"]
  }
}

data "aws_security_group" "internal" {
  filter {
    name   = "group-name"
    values = ["${local.prefix}_internal"]
  }
}

# Target groups créées par le module alb du student X (nom = <prefix avec tirets>-<app>)
data "aws_lb_target_group" "app" {
  for_each = local.apps

  name = "${replace(local.prefix, "_", "-")}-${each.key}"
}

module "asg" {
  source   = "./modules/asg"
  for_each = local.apps

  name               = "${local.prefix}_${each.key}"
  ami_id             = data.aws_ami.al2023.id
  instance_type      = var.instance_type
  min_size           = 2
  max_size           = 2
  subnet_ids         = [data.aws_subnet.private.id]
  security_group_ids = [data.aws_security_group.internal.id]
  target_group_arns  = [data.aws_lb_target_group.app[each.key].arn]

  user_data = <<-EOF
    #!/bin/bash
    TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
    ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    mkdir -p /srv/${each.key}
    echo "<h1>${each.key}</h1><p>served by $ID</p>" | tee /srv/index.html /srv/${each.key}/index.html
    cd /srv && nohup python3 -m http.server 80 >/dev/null 2>&1 &
  EOF
}
