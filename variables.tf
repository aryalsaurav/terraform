variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "ecs_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ecs_min_size" {
  type    = number
  default = 1

}

variable "ecs_max_size" {
  type    = number
  default = 2

}

variable "ecs_desired_size" {
  type    = number
  default = 1

}