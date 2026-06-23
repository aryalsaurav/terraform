resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    local.common_tags,
    {
      Name : "${local.prefix}-vpc"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-igw"
    }
  )
}