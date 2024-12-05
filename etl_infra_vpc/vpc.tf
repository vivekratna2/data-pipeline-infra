data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "gbd_data_platform_vpc"
  }
}
_on_launch = true
resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 2 + count.index)
  vpc_id                  = aws_vpc.default.id
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip

  tags = {
    Name = "etl_public"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.default.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]


  tags = {
    Name = "etl_private"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "etl_ig"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "etl-private-rtb"
  }
}
