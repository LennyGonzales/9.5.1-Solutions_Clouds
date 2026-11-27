# À communiquer au student A (variable bastion_sg_id de network_rds)
output "bastion_security_group" {
  value = {
    id   = aws_security_group.bastion.id
    name = aws_security_group.bastion.name
  }
}

output "rds_security_group_id" {
  value = data.aws_security_group.rds.id
}
