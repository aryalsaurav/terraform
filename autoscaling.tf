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

resource "aws_appautoscaling_target" "ecs" {
  service_namespace = "ecs"
  resource_id       = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.server.name}"

  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.ecs_min_size
  max_capacity = var.ecs_max_size

}

resource "aws_appautoscaling_policy" "cpu" {
  name = "${local.prefix}-cpu-scaling"

  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

}