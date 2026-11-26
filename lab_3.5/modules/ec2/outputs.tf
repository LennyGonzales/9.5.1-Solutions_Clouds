output "instance_id" {
  value = aws_instance.this.id
}

output "ami_id" {
  value = data.aws_ami.ami.id
}

output "subnet_id" {
  value = data.aws_subnet.subnet.id
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/lab_3 ${var.ssh_user}@${aws_instance.this.public_ip}"
}