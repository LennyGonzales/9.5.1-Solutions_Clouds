# module "nginx" {
#   source = "./modules/nginx"

#   image_name = "nginx:latest"
#   container_memory = 1024
#   container_privileged = true
#   container_count = 2
# }

module "nginx" {
  source        = "github.com/18Nilsou/terraform-docker-nginx?ref=v1.0.0"
  nbr_container = 3
  starting_port = 3000
}