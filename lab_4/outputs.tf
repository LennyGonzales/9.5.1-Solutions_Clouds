output "asg_name" {
  value = module.instance.asg_name
}

output "instance_ids" {
  value = module.instance.instance_ids
}

output "ami_id" {
  value = module.instance.ami_id
}

output "subnet_id" {
  value = module.instance.subnet_id
}

output "public_ips" {
  value = module.instance.public_ips
}

output "ssh_commands" {
  value = module.instance.ssh_commands
}
