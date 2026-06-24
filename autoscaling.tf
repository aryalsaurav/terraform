resource "aws_autoscaling_group" "ecs" {
  name = "${local.prefix}-ecs-asg"

  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size
  desired_capacity = var.ecs_desired_size

  vpc_zone_identifier = [
    for subnet in aws_subnet.private :
    subnet.id
  ]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.prefix}-ecs-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_nat_gateway.main, aws_route_table_association.private]
}