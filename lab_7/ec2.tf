# Student Y : instance EC2 dont le rôle n'accède qu'au préfixe shared/ du bucket du lab

locals {
  shared_prefix = "shared"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "ec2" {
  name = "${local.prefix}_lab7_ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Pas de s3:DeleteObject, pas d'autre bucket, pas d'autre préfixe
resource "aws_iam_role_policy" "s3_shared" {
  name = "s3_shared_prefix"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "ListSharedPrefix"
        Effect    = "Allow"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.shared.arn
        Condition = { StringLike = { "s3:prefix" = "${local.shared_prefix}/*" } }
      },
      {
        Sid      = "ReadWriteShared"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.shared.arn}/${local.shared_prefix}/*"
      }
    ]
  })
}

# Accès SSH restreint à mon IP (Session Manager refusé à nos users IAM : pas de ssm:SendCommand)
resource "aws_security_group" "ec2" {
  name        = "${local.prefix}_lab7_ec2"
  description = "SSH from my IP only"

  tags = {
    Name = "${local.prefix}_lab7_ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_key_pair" "ec2" {
  key_name   = "${local.prefix}_lab7_ec2"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.prefix}_lab7_ec2"
  role = aws_iam_role.ec2.name
}

# Sans subnet_id : VPC par défaut, subnet public
resource "aws_instance" "lab7" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.ec2.key_name

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${local.prefix}_lab7"
    Pair = local.prefix
    Lab  = "lab7"
  }
}

output "ssh_command" {
  value = "ssh -i ${trimsuffix(var.public_key_path, ".pub")} ec2-user@${aws_instance.lab7.public_ip}"
}
