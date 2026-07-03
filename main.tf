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