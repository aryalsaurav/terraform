output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "iam_instance_profile_arn" {
  value = aws_iam_instance_profile.ecs_instance.arn
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}