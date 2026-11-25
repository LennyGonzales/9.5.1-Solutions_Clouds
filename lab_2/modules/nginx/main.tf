terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pulls the image
resource "docker_image" "nginx" {
  name = var.image_name
}

# Create a container
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx-${count.index}"
  ports {
    internal = 80
    external = 3000 + count.index
  }
  command = [
    "/bin/sh", "-c",
    "echo \"<h1>Hostname : $(hostname)</h1>\" > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"
  ]

  memory = var.container_memory
  privileged = var.container_privileged
  count = var.container_count
}
