output "celery_log_group_name" {
  value = aws_cloudwatch_log_group.celery.name
}

output "server_log_group_name" {
  value = aws_cloudwatch_log_group.server.name
}