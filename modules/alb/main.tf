resource "aws_alb_target_group" "server" {
  vpc_id   = var.vpc_id
  name     = "${var.prefix}-tg"
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
    var.tags,
    {
      Name = "${var.prefix}-tg"
    }
  )
}

resource "aws_lb" "server" {
  name               = "${var.prefix}-alb"
  load_balancer_type = "application"

  security_groups = [
    var.alb_sg_id
  ]

  subnets = [
    var.public_subnets["public_a"],
    var.public_subnets["public_b"]
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-alb"
    }
  )
}

resource "aws_acm_certificate" "server" {
  domain_name       = "renter.aryalsaurav.com.np"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "server" {
  certificate_arn = aws_acm_certificate.server.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.server.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.server.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.server.arn
  }
}
