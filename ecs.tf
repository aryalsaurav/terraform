resource "aws_ecr_repository" "web" {
  name                 = "${var.project_name}/backend"
  image_tag_mutability = "IMMUTABLE"

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
      image_url    = "${aws_ecr_repository.web.repository_url}:latest"
      log_group    = aws_cloudwatch_log_group.server.name
      aws_region   = var.aws_region
      env_file_arn = "${aws_s3_bucket.env_files.arn}/backend.env"
    }
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-web-task"
    }
  )
}

resource "aws_ecs_task_definition" "migration" {
  family                   = "${local.prefix}-migration"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = 512
  memory = 500

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(
    "${path.module}/templates/migration-container-definition.json.tpl",
    {
      image_url    = "${aws_ecr_repository.web.repository_url}:latest"
      log_group    = aws_cloudwatch_log_group.server.name
      aws_region   = var.aws_region
      env_file_arn = "${aws_s3_bucket.env_files.arn}/backend.env"
    }
  )

}

resource "aws_ecs_service" "server" {
  name            = "${local.prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn

  desired_count = var.ecs_desired_size

  network_configuration {
    subnets = [
      aws_subnet.private["private_a"].id,
      aws_subnet.private["private_b"].id,
    ]

    security_groups = [
      aws_security_group.web_task.id
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
      task_definition
    ]
  }

  depends_on = [aws_lb_listener.http]

}