resource "aws_ecr_repository" "web" {
  name                 = "${var.project_name}/backend"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter      = "latest"
    filter_type = "WILDCARD"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-cluster"
    }
  )
}


resource "aws_ecs_task_definition" "web" {
  family                   = "${local.prefix}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 720

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(
    "${path.module}/templates/web-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = aws_cloudwatch_log_group.server.name
      aws_region    = var.aws_region
      env_file_arn  = "${aws_s3_bucket.env_files.arn}/backend.env"
      db_secret_arn = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}"
    }
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-web-task"
    }
  )
}

resource "aws_ecs_service" "server" {
  name                 = "${local.prefix}-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.web.arn
  force_new_deployment = true
  # launch_type = "EC2"

  desired_count = var.ecs_desired_size

  network_configuration {
    subnets = values(module.vpc.private_subnet_ids)

    security_groups = [
      module.security.task_sg_id
    ]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.server.arn
    container_name   = "server"
    container_port   = 8000
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

  depends_on = [aws_lb_listener.http]

}

resource "aws_ecs_task_definition" "migration" {
  family                   = "${local.prefix}-migration"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(
    "${path.module}/templates/migration-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = aws_cloudwatch_log_group.server.name
      aws_region    = var.aws_region
      env_file_arn  = "${aws_s3_bucket.env_files.arn}/backend.env"
      db_secret_arn = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}"
    }
  )

}

resource "aws_ecs_task_definition" "celery" {
  family                   = "${local.prefix}-celery"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 720

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(
    "${path.module}/templates/celery-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = aws_cloudwatch_log_group.celery.name
      aws_region    = var.aws_region
      env_file_arn  = "${aws_s3_bucket.env_files.arn}/backend.env"
      db_secret_arn = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}"
    }
  )
}


resource "aws_ecs_service" "celery" {
  name                 = "${local.prefix}-celery-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.celery.arn
  force_new_deployment = true
  # launch_type = "EC2"

  desired_count = 1

  network_configuration {
    subnets = values(module.vpc.private_subnet_ids)

    security_groups = [
      module.security.task_sg_id
    ]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.celery.name
    weight            = 1
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

}

resource "aws_ecs_task_definition" "beat" {
  family                   = "${local.prefix}-beat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 720

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(
    "${path.module}/templates/beat-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = aws_cloudwatch_log_group.celery.name
      aws_region    = var.aws_region
      env_file_arn  = "${aws_s3_bucket.env_files.arn}/backend.env"
      db_secret_arn = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}"
    }
  )
}

resource "aws_ecs_service" "beat" {
  name                 = "${local.prefix}-beat-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.beat.arn
  launch_type          = "EC2"
  force_new_deployment = true

  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets = [
      module.vpc.private_subnet_ids["private_a"],
      module.vpc.private_subnet_ids["private_b"]
    ]

    security_groups = [
      module.security.task_sg_id
    ]
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

}