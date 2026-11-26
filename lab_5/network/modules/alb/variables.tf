variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "apps" {
  description = "Une target group et une règle de chemin /<app> par application"
  type        = list(string)
  default     = ["nginx", "tomcat"]
}
