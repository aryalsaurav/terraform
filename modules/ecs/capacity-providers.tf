resource "aws_ecs_capacity_provider" "main" {
  name = "${var.prefix}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn

    managed_scaling {
      status                 = "ENABLED"
      target_capacity        = 85
      instance_warmup_period = 120
    }
  }
}

resource "aws_ecs_capacity_provider" "celery" {
  name = "${var.prefix}-capacity-provider-celery"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_celery.arn

    managed_scaling {
      status                 = "ENABLED"
      target_capacity        = 85
      instance_warmup_period = 120
    }
  }

  depends_on = [aws_ecs_capacity_provider.main]
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.main.name,
    aws_ecs_capacity_provider.celery.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
  }

}