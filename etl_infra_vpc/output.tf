output "vpc_id" {
  value = aws_vpc.default.id
}

output "private_subnet_ip_1" {
  value = aws_subnet.private[0].id
}

output "private_subnet_ip_2" {
  value = aws_subnet.private[1].id
}

output "public_subnet_ip_1" {
  value = aws_subnet.public[0].id
}

output "public_subnet_ip_2" {
  value = aws_subnet.public[1].id
}