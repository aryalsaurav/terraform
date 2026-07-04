variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = map(string)
}

variable "private_subnets" {
  type = map(string)
}

variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "ecs_desired_size" {
  type = number
}

variable "task_sg_id" {
  type = string
}

variable "server_tg_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "ecs_instance_type" {
  type = string
}

variable "instance_sg_id" {
  type = string
}

variable "iam_instance_profile_arn" {
  type = string
}

variable "ecs_max_size" {
  type = number
}

variable "ecs_min_size" {
  type = number
}

variable "db_secret_arn" {
  type = string
}

variable "env_bucket_arn" {
  type = string
}

variable "celery_log_group_name" {
  type = string
}

variable "server_log_group_name" {
  type = string
}