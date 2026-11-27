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

variable "student_x" {
  type    = number
  default = 12
}

variable "student_y" {
  type    = number
  default = 6
}

# Ton IP publique en /32 (ex: 203.0.113.7/32), sans défaut pour ne jamais l'écrire dans le repo
variable "ssh_cidr" {
  type = string
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
