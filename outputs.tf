output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.main.id
}

output "subnet_ids" {
  value = {
    for k, subnet in aws_subnet.public :
    k => subnet.id
  }
}

output "eip" {
  value = aws_eip.nat.id
}