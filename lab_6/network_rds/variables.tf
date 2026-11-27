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

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

# RDS ne propose plus la 14.7 : on fixe la version majeure et RDS choisit la mineure par défaut
variable "db_engine_version" {
  type    = string
  default = "14"
}

variable "db_allocated_storage" {
  type    = number
  default = 20

  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "RDS PostgreSQL en gp3 exige au moins 20 Go."
  }
}

variable "db_name" {
  type    = string
  default = "labdb"
}

variable "db_username" {
  type    = string
  default = "labadmin"
}

# ID du security group du bastion (fourni par le student B), null tant qu'il n'existe pas
variable "bastion_sg_id" {
  type    = string
  default = null
}
