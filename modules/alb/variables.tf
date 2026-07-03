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

variable "alb_sg_id" {
  type = string
}