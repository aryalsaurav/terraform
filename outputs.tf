output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  value = {
    for k, subnet in aws_subnet.public :
    k => subnet.id
  }
}

output "private_subnet_ids" {
  value = {
    for k, subnet in aws_subnet.private :
    k => subnet
  }
}

output "eip" {
  value = aws_eip.nat.id
}

output "task_sg_id" {
  value = aws_security_group.web_task.id
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