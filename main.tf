terraform {
  backend "s3" {
    bucket       = "${local.prefix}-terraform-state"
    key          = "${local.prefix}/terraform.tfstate"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true

  }
}