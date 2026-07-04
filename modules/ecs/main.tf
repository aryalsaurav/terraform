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
  name = "${var.prefix}-cluster"

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-cluster"
    }
  )
}


resource "aws_ecs_task_definition" "web" {
  family                   = "${var.prefix}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 720

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  container_definitions = templatefile(
    "${path.module}/templates/web-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = var.server_log_group_name
      aws_region    = var.aws_region
      env_file_arn  = "${var.env_bucket_arn}/backend.env"
      db_secret_arn = var.db_secret_arn
    }
  )

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-web-task"
    }
  )
}

resource "aws_ecs_service" "server" {
  name                 = "${var.prefix}-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.web.arn
  force_new_deployment = true
  # launch_type = "EC2"

  desired_count = var.ecs_desired_size

  network_configuration {
    subnets = values(var.private_subnets)

    security_groups = [
      var.task_sg_id
    ]
  }

  load_balancer {
    target_group_arn = var.server_tg_arn
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
}

resource "aws_ecs_task_definition" "migration" {
  family                   = "${var.prefix}-migration"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  container_definitions = templatefile(
    "${path.module}/templates/migration-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = var.server_log_group_name
      aws_region    = var.aws_region
      env_file_arn  = "${var.env_bucket_arn}/backend.env"
      db_secret_arn = var.db_secret_arn
    }
  )

}

resource "aws_ecs_task_definition" "celery" {
  family                   = "${var.prefix}-celery"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 720

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  container_definitions = templatefile(
    "${path.module}/templates/celery-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = var.celery_log_group_name
      aws_region    = var.aws_region
      env_file_arn  = "${var.env_bucket_arn}/backend.env"
      db_secret_arn = var.db_secret_arn
    }
  )
}


resource "aws_ecs_service" "celery" {
  name                 = "${var.prefix}-celery-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.celery.arn
  force_new_deployment = true
  # launch_type = "EC2"

  desired_count = 1

  network_configuration {
    subnets = values(var.private_subnets)

    security_groups = [
      var.task_sg_id
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
  family                   = "${var.prefix}-beat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 720

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  container_definitions = templatefile(
    "${path.module}/templates/beat-container-definition.json.tpl",
    {
      image_url     = "${aws_ecr_repository.web.repository_url}:latest"
      log_group     = var.celery_log_group_name
      aws_region    = var.aws_region
      env_file_arn  = "${var.env_bucket_arn}/backend.env"
      db_secret_arn = var.db_secret_arn
    }
  )
}

resource "aws_ecs_service" "beat" {
  name                 = "${var.prefix}-beat-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.beat.arn
  launch_type          = "EC2"
  force_new_deployment = true

  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets = [
      var.private_subnets["private_a"],
      var.private_subnets["private_b"]
    ]

    security_groups = [
      var.task_sg_id
    ]
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

}