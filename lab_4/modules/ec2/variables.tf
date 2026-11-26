variable "name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_id" {
  type = string
}

variable "availability_zone" {
  type    = string
  default = "eu-west-3a"
}

variable "ssh_user" {
  type    = string
  default = "ec2-user"
}

variable "public_key_path" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}
