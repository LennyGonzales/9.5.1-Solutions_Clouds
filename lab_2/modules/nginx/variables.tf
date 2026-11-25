variable "image_name" {
  type = string
  default = "nginx:latest"
}

variable "container_memory" {
  type = number
  default = 1024
}

variable "container_privileged" {
  type = bool
  default = false
}

variable "container_count" {
  type = number
  default = 1
}
