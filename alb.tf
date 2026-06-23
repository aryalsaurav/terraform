resource "aws_alb_target_group" "server" {
  vpc_id   = aws_vpc.main.id
  name     = "${local.prefix}-tg"
  protocol = "HTTP"
  port     = 8000

  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-tg"
    }
  )
}

resource "aws_lb" "server" {
  name               = "${local.prefix}-alb"
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public["public_a"].id,
    aws_subnet.public["public_b"].id
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-alb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.server.arn
  }
}