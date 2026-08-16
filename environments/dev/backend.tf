# terraform {
#   backend "s3" {
#     encrypt      = true
#     use_lockfile = true

#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}