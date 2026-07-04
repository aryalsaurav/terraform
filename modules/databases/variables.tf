variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnets" {
  type = map(string)
}

variable "db_sg_id" {
  type = string
}

variable "redis_sg_id" {
  type = string
}