output "instance_id" {
  value = module.instance.instance_id
}

output "ami_id" {
  value = module.instance.ami_id
}

output "subnet_id" {
  value = module.instance.subnet_id
}

output "public_dns" {
  value = module.instance.public_dns
}

output "public_ip" {
  value = module.instance.public_ip
}

output "ssh_command" {
  value = module.instance.ssh_command
}
