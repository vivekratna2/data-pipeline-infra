resource "aws_security_group" "etl_postgres_redis_security_group" {
  name   = "etl_postgres_redis_security_group_${terraform.workspace}"
  vpc_id = data.terraform_remote_state.etl_vpc.outputs.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["10.20.0.0/16"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["192.168.0.0/16"]
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

resource "aws_security_group" "etl_mongodb_security_group" {
  name   = "etl_mongodb_security_group_${terraform.workspace}"
  vpc_id = data.terraform_remote_state.etl_vpc.outputs.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["10.20.0.0/16"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port   = 27017
    protocol    = "tcp"
    to_port     = 27017
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

