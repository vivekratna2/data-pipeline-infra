data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "html-parser-vpc" {
  cidr_block = "10.51.0.0/16"
  tags = {
    Name = "html-parser-vpc"
  }
}


/* public subnet */
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.html-parser-vpc.id
  count                   = length(var.public_subnet_cidr)
  cidr_block              = var.public_subnet_cidr[count.index]
  tags = {
    Name = "html_parser_public_subnet"
  }
}

/* private subnet */
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.html-parser-vpc.id
  count                   = length(var.private_subnet_cidr)
  cidr_block              = var.private_subnet_cidr[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "html_parser_private_subnet"
  }
}



/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.html-parser-vpc.id}"
  tags = {
    Name        = "html_parser_igw"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name = "html_parser_eip"
  }
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "html_parser_nat"
  }
}

#Public Route Table
resource "aws_route_table" "rt_public" {
  vpc_id = "${aws_vpc.html-parser-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "html_parser_public-route-table"
  }
}

#Public Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.rt_public.id
}



/* Routing table for private subnet */
resource "aws_route_table" "rt_private" {
  vpc_id = "${aws_vpc.html-parser-vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name        = "html_parser_private-route-table"
  }
}


#Private Route Table Association
resource "aws_route_table_association" "private_sub" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.rt_private.id
}

# VPC endpoint for S3
resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  vpc_id = "${aws_vpc.html-parser-vpc.id}"
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = ["${aws_route_table.rt_private.id}"]
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "vpc endpoint for S3"
  }
}

# VPC endpoint for Dynamodb
resource "aws_vpc_endpoint" "vpc_endpoint_dynamodb" {
  vpc_id = "${aws_vpc.html-parser-vpc.id}"
  service_name    = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = ["${aws_route_table.rt_private.id}"]
  vpc_endpoint_type = "Gateway"

   tags = {
    Name = "vpc endpoint for Dynamodb"
  }
}

