output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  value = {
    for k, subnet in aws_subnet.public :
    k => subnet.id
  }
}

output "private_subnet_ids" {
  value = {
    for k, subnet in aws_subnet.private :
    k => subnet
  }
}

output "eip" {
  value = aws_eip.nat.id
}

output "task_sg_id" {
  value = aws_security_group.web_task.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.web.repository_url
}

output "s3_env_url" {
  value = aws_s3_bucket.env_files.arn
}

output "aws_region" {
  value = var.aws_region
}
