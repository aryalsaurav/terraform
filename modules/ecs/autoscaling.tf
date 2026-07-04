resource "aws_autoscaling_group" "ecs" {
  name = "${var.prefix}-ecs-asg"

  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size
  desired_capacity = var.ecs_desired_size

  vpc_zone_identifier = values(var.private_subnets)


  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-ecs-instance"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_appautoscaling_target" "ecs" {
  service_namespace = "ecs"
  resource_id       = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.server.name}"

  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.ecs_min_size
  max_capacity = var.ecs_max_size

}

resource "aws_appautoscaling_policy" "cpu" {
  name = "${var.prefix}-cpu-scaling"

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


resource "aws_autoscaling_group" "ecs_celery" {
  name = "${var.prefix}-ecs-asg-celery"

  min_size         = 1
  max_size         = 10
  desired_capacity = 1

  vpc_zone_identifier = values(var.private_subnets)

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-ecs-celery-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_appautoscaling_target" "ecs_celery" {
  service_namespace = "ecs"
  resource_id       = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.celery.name}"

  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = 1
  max_capacity = var.ecs_max_size

}


resource "aws_appautoscaling_policy" "celery_cpu" {
  name = "${var.prefix}-celery-cpu-scaling"

  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs_celery.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_celery.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_celery.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

}