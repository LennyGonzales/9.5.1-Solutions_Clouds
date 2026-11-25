output "container_name" {
  value = docker_container.nginx[*].name
}

output "container_ports" {
  value = docker_container.nginx[*].ports
}