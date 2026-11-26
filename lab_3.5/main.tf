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

module "instance" {
  source = "./modules/ec2"
  name = var.name
  instance_type = var.instance_type
  vpc_id = var.vpc_id
  availability_zone = var.availability_zone
  ssh_user = var.ssh_user
  public_key_path = var.public_key_path
}