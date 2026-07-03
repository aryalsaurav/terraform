output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "task_sg_id" {
  value = aws_security_group.web_task.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "instance_sg_id" {
  value = aws_security_group.ecs_instance.id
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}