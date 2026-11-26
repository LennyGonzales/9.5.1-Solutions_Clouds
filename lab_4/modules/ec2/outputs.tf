output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "instance_ids" {
  value = data.aws_instances.asg.ids
}

output "ami_id" {
  value = data.aws_ami.ami.id
}

output "subnet_id" {
  value = data.aws_subnet.subnet.id
}

output "public_ips" {
  value = data.aws_instances.asg.public_ips
}

output "ssh_commands" {
  value = [for ip in data.aws_instances.asg.public_ips : "ssh -i ${trimsuffix(var.public_key_path, ".pub")} ${var.ssh_user}@${ip}"]
}
