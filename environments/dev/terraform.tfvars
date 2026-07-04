project_name = "learner"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnets = {
  "public_a" = {
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  "public_b" = {
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }
}

private_subnets = {
  "private_a" = {
    cidr = "10.0.100.0/24"
    az   = "ap-south-1a"
  },
  "private_b" = {
    cidr = "10.0.101.0/24"
    az   = "ap-south-1b"
  }
}