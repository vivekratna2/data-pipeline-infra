resource "aws_security_group" "etl_scheduler_sg" {
  name   = "etl_scheduler_sg_${terraform.workspace}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8793
    protocol    = "tcp"
    to_port     = 8793
    cidr_blocks = ["10.20.0.0/16"]
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

resource "aws_security_group" "etl_worker_sg" {
  name   = "etl_worker_sg_${terraform.workspace}"
  vpc_id = var.vpc_id

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

resource "aws_security_group" "etl_webserver_sg" {
  name   = "etl_webserver_sg_${terraform.workspace}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
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