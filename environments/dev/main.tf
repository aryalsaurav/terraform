module "vpc" {
  source          = "../../modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  prefix          = local.prefix
  tags            = local.common_tags
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
  prefix = local.prefix
}

module "alb" {
  source = "../../modules/alb"

  vpc_id         = module.vpc.vpc_id
  alb_sg_id      = module.security.alb_sg_id
  public_subnets = module.vpc.public_subnet_ids
  tags           = local.common_tags
  prefix         = local.prefix

}

module "ecs" {
  source = "../../modules/ecs"

  vpc_id                   = module.vpc.vpc_id
  public_subnets           = module.vpc.public_subnet_ids
  private_subnets          = module.vpc.private_subnet_ids
  aws_region               = var.aws_region
  project_name             = var.project_name
  ecs_desired_size         = var.ecs_desired_size
  task_sg_id               = module.security.task_sg_id
  server_tg_arn            = module.alb.server_tg_arn
  task_role_arn            = module.iam.task_role_arn
  execution_role_arn       = module.iam.execution_role_arn
  instance_sg_id           = module.security.instance_sg_id
  ecs_instance_type        = var.ecs_instance_type
  iam_instance_profile_arn = module.iam.iam_instance_profile_arn
  ecs_max_size = var.ecs_max_size
  ecs_min_size = var.ecs_min_size
  celery_log_group_name = module.monitoring.celery_log_group_name
  server_log_group_name = module.monitoring.server_log_group_name
  db_secret_arn = module.databases.db_secret_arn
  env_bucket_arn = module.s3.env_bucket_arn

  tags   = local.common_tags
  prefix = local.prefix

}

module "iam" {
  source = "../../modules/iam"

  prefix = local.prefix
  tags   = local.common_tags

  github_oidc_arn = var.github_oidc_arn
  github_repo     = var.github_repo
  ecr_repo_arn = module.ecs.ecr_repo_arn
  env_bucket_arn = module.s3.env_bucket_arn
  app_storage_bucket_arn = module.s3.app_storage_bucket_arn
}

module "databases" {
  source = "../../modules/databases"

  prefix = local.prefix
  tags = local.common_tags

  private_subnets = module.vpc.private_subnet_ids
  project_name = var.project_name
  environment = var.environment
  redis_sg_id = module.security.redis_sg_id
  db_sg_id = module.security.db_sg_id
}

module "s3" {
  source = "../../modules/s3"

  prefix = local.prefix
  tags = local.common_tags

}

module "monitoring" {
  source = "../../modules/monitoring"

  prefix = local.prefix
  tags = local.common_tags
}
