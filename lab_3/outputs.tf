output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/lab_3 ${var.ssh_user}@${aws_instance.this.public_ip}"
}