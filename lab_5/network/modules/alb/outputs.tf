output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_groups" {
  value = { for app, tg in aws_lb_target_group.app : app => { name = tg.name, arn = tg.arn } }
}
