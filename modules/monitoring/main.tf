resource "aws_cloudwatch_log_group" "server" {
  name = "ecs/${var.prefix}-server"

  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-server-logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "celery" {
  name = "ecs/${var.prefix}-celery"

  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-celery-logs"
    }
  )
}