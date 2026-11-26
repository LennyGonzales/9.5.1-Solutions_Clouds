variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "instance_type doit être t2.micro ou t3.micro."
  }
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  description = "Target groups de l'ALB placé devant l'ASG"
  type        = list(string)
  default     = []
}

variable "user_data" {
  type    = string
  default = ""
}
