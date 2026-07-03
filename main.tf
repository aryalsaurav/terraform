terraform {
  backend "s3" {
    encrypt      = true
    use_lockfile = true

  }
}


module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  prefix          = local.prefix
  tags            = local.common_tags
}

module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
  prefix = local.prefix
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.vpc.vpc_id
  alb_sg_id      = module.security.alb_sg_id
  public_subnets = module.vpc.public_subnet_ids
  tags           = local.common_tags
  prefix         = local.prefix

}