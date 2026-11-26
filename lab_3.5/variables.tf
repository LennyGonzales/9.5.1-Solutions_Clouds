variable "region" {
  type = string
  default = "eu-west-3"
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "availability_zone" {
  type = string
  default = "eu-west-3a"
}

variable "name" {
  type = string
  default = "lab3.5-student_12-"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "ssh_user" {
  type= string
  default = "ec2-user"
}

variable "public_key_path" {
  type = string
  default = "~/.ssh/id_ed25519.pub"
}