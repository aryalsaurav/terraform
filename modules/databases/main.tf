resource "aws_db_subnet_group" "main" {
  name       = "${var.prefix}-db"
  subnet_ids = values(var.private_subnets)
}

# resource "random_password" "postgres" {
#     length = 32
#     special = true
# }

# resource "aws_secretsmanager_secret" "postgres" {
#     name = "${var.prefix}/postgres"
#     tags = var.common_tags

# }

# resource "aws_secretsmanager_secret_version" "postgres" {
#   secret_id = aws_secretsmanager_secret.postgres.id
#   secret_string = jsonencode({
#     username = "postgres"
#     password = random_password.postgres.result
#   })
# }


resource "aws_db_instance" "postgres" {
  identifier = "${var.prefix}-postgres"

  engine         = "postgres"
  engine_version = "18"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  db_name  = "${var.project_name}_${var.environment}"
  username = "postgres"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately = true

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-postgres"
    }
  )


}


resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.prefix}-redis"
  subnet_ids = values(var.private_subnets)
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id         = "${var.prefix}-redis"
  engine             = "redis"
  node_type          = "cache.t4g.micro"
  num_cache_nodes    = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.redis_sg_id]
}