output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "task_sg_id" {
  value = module.security.task_sg_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.web.repository_url
}

output "s3_env_url" {
  value = aws_s3_bucket.env_files.arn
}

output "aws_region" {
  value = var.aws_region
}

output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_secret_arn" {
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.server.name
}

output "web_task_family" {
  value = aws_ecs_task_definition.web.family
}

output "migration_task_family" {
  value = aws_ecs_task_definition.migration.family
}

output "alb_dns" {
  value = module.alb.alb_dns

}

output "acm_validation_record" {
  value = module.alb.acm_validation_record
}