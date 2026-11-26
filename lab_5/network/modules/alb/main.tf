locals {
  base_name = replace(var.name, "_", "-")
}

resource "aws_lb" "this" {
  name               = "${local.base_name}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  tags = {
    Name = "${var.name}_alb"
  }
}

resource "aws_lb_target_group" "app" {
  for_each = toset(var.apps)

  name     = "${local.base_name}-${each.key}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/"
    matcher = "200-399"
  }

  tags = {
    Name = "${var.name}_${each.key}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found: use /nginx or /tomcat"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "app" {
  for_each = toset(var.apps)

  listener_arn = aws_lb_listener.http.arn
  priority     = index(var.apps, each.key) + 1

  condition {
    path_pattern {
      values = ["/${each.key}", "/${each.key}/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[each.key].arn
  }
}
