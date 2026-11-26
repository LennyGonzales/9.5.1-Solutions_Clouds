terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-w9e85"
    key = "global/s3/student_12/terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "instance" {
  source = "./modules/ec2"
  name = "${var.name}${terraform.workspace}-"
  instance_type = var.instance_type
  vpc_id = var.vpc_id
  availability_zone = var.availability_zone
  ssh_user = var.ssh_user
  public_key_path = var.public_key_path
  min_size = var.min_size
  max_size = var.max_size
}