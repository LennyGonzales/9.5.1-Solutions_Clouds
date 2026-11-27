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

# Ton IP publique en /32 (ex: 203.0.113.7/32), sans défaut pour ne jamais l'écrire dans le repo
variable "ssh_cidr" {
  type = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "ssh_cidr doit être un CIDR IPv4 valide, ex: 203.0.113.7/32."
  }
}
