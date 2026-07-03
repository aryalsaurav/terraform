resource "aws_security_group" "alb" {
  name        = "${local.prefix}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-alb-sg"
    }
  )
}
resource "aws_security_group" "web_task" {
  name        = "${local.prefix}-web-task-sg"
  description = "Task Security Group"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-task-sg"
    }
  )
}
resource "aws_security_group" "db" {
  name        = "${local.prefix}-web-db-sg"
  description = "Db Security Group"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-db-sg"
    }
  )
}

resource "aws_security_group" "ecs_instance" {
  name        = "${local.prefix}-ecs-instance-sg"
  description = "Ecs instance sg"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-ecs-instance-sg"
    }
  )

}

resource "aws_vpc_security_group_egress_rule" "name" {
  security_group_id = aws_security_group.ecs_instance.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_to_web_task" {
  security_group_id = aws_security_group.web_task.id

  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_task_to_db" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web_task.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_outbound" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "web_all_outbound" {
  security_group_id = aws_security_group.web_task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "db_all_outbound" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "redis" {
  name        = "${local.prefix}-redis-sg"
  description = "Redis security group"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-redis-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "task_redis_sg" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.web_task.id

  ip_protocol = "tcp"
  from_port   = 6379
  to_port     = 6379
}

resource "aws_vpc_security_group_egress_rule" "redis_all_outbound" {
  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}