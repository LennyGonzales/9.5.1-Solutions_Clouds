variable "image_name" {
  type = string
  default = "nginx:latest"
  validation {
    condition     = can(regex("^nginx", var.image_name))
    error_message = "image_name doit être une image nginx"
  }
}

variable "container_memory" {
  type = number
  default = 1024
  validation {
    condition = var.container_memory > 0 && var.container_memory <= 2048
    error_message = "Container memory must be greater than 0 and less than or equal to 2048"
  }
}

variable "container_privileged" {
  type = bool
  default = false
  validation {
    condition = var.container_privileged == true || var.container_privileged == false
    error_message = "Container privileged must be true or false"
  }
}

variable "container_count" {
  type = number
  default = 1
  validation {
    condition = var.container_count > 0
    error_message = "Container count must be greater than 0"
  }
}
