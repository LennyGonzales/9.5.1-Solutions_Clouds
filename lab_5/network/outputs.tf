output "vpc_id" {
  value = data.aws_vpc.lab.id
}

output "vpc_cidr" {
  value = data.aws_vpc.lab.cidr_block
}

output "private_subnet" {
  value = {
    id   = aws_subnet.private.id
    cidr = aws_subnet.private.cidr_block
    az   = aws_subnet.private.availability_zone
  }
}

output "security_groups" {
  value = {
    public   = { id = aws_security_group.public.id, name = aws_security_group.public.name }
    internal = { id = aws_security_group.internal.id, name = aws_security_group.internal.name }
  }
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_groups" {
  value = module.alb.target_groups
}

output "public_subnets" {
  value = {
    for s in [aws_subnet.public_a, aws_subnet.public_b] : s.tags.Name => {
      id   = s.id
      cidr = s.cidr_block
      az   = s.availability_zone
    }
  }
}
