module "nginx" {
  source = "./modules/nginx"

  image_name = "nginx:latest"
  container_memory = 1024
  container_privileged = true
  container_count = 2
}