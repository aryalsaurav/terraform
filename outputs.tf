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
  value = module.ecs.ecr_repository_url
}

output "aws_region" {
  value = var.aws_region
}

output "db_endpoint" {
  value = module.databases.db_address
}

output "redis_endpoint" {
  value = module.databases.redis_endpoint
}

output "github_deploy_role_arn" {
  value = module.iam.github_deploy_role_arn
}

output "cluster_name" {
  value = module.ecs.cluster_name
}

output "service_name" {
  value = module.ecs.server_service_name
}

output "web_task_family" {
  value = module.ecs.server_task_family
}

output "migration_task_family" {
  value = module.ecs.migration_task_family
}

output "alb_dns" {
  value = module.alb.alb_dns

}

output "acm_validation_record" {
  value = module.alb.acm_validation_record
}