output "rds_security_group" {
  value = {
    id   = aws_security_group.rds.id
    name = aws_security_group.rds.name
  }
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_engine_version" {
  value = aws_db_instance.postgres.engine_version_actual
}

output "db_subnet_group" {
  value = {
    name       = aws_db_subnet_group.rds.name
    subnet_ids = aws_db_subnet_group.rds.subnet_ids
  }
}

output "ssm_parameters" {
  value = concat(
    [for p in aws_ssm_parameter.db : p.name],
    [aws_ssm_parameter.db_password.name],
  )
}
