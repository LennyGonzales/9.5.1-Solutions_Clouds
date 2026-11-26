variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "vpc_name" {
  type    = string
  default = "Lab5-6"
}

variable "student_x" {
  type    = number
  default = 12
}

variable "student_y" {
  type    = number
  default = 5
}
