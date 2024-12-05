output "vpc" {
    value       = aws_vpc.html-parser-vpc.id
    description = "VPC"
}

output "public_subnet" {
    value = "${aws_subnet.public.*.id}"
    description = "public subnet"
}

output "private_subnet" {
  value       = "${aws_subnet.private.*.id}"
  description = "private subnet"
}

output "nat_eip" {
  value       = "${aws_eip.nat_eip}"
  description = "nat_eip"
}