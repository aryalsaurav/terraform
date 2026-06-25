resource "aws_cloudwatch_log_group" "server" {
  name = "ecs/${local.prefix}-server"

  retention_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-server-logs"
    }
  )
}