output "db_secret_arn" {
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "db_address" {
  value = aws_db_instance.postgres.address
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}