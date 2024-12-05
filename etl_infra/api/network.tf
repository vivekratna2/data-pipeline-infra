resource "aws_security_group" "etl_api_security_group" {
  name   = "etl_api_security_group_${terraform.workspace}"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["172.31.0.0/16"]
    description = "us-east-1 default vpc"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["192.168.0.0/16"]
    description = "GBD Local"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["202.166.206.49/32"]
    description = "GBD-wlink"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["110.34.1.227/32"]
    description = "GBD-subisu"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["52.87.5.132/32"]
    description = "GBD-wlink"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["10.20.2.0/24"]
    description = ""
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["10.20.3.0/24"]
    description = ""
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["52.71.86.44/32"]
    description = ""
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["35.168.47.200/32"]
    description = ""
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "etl"
    Stage   = terraform.workspace
  }
}
