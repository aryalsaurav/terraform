output "ecr_repository_url" {
  value = aws_ecr_repository.web.repository_url
}

output "ecr_repo_arn" {
  value = aws_ecr_repository.web.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "server_service_name" {
  value = aws_ecs_service.server.name
}

output "server_task_family" {
  value = aws_ecs_task_definition.web.family
}

output "migration_task_family" {
  value = aws_ecs_task_definition.migration.family
}

