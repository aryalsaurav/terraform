variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "github_oidc_arn" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "ecr_repo_arn" {
  type = string
}

variable "env_bucket_arn" {
  type = string
}

variable "app_storage_bucket_arn" {
  type = string
}