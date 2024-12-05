resource "aws_instance" "db_instance" {
  ami                         = "ami-098e42ae54c764c35"
  associate_public_ip_address = true
  instance_type               = "t3.large"
  key_name                    = "etl-us-west-2"
  vpc_security_group_ids      = [aws_security_group.etl_postgres_redis_security_group.id]
  user_data = templatefile(
    "${path.module}/server-userdata.tpl",
    {
      redis_pass = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PASSWORD"]
    }
  )
  subnet_id = data.terraform_remote_state.etl_vpc.outputs.public_subnet_ip_1

  tags = {
    Name        = "etl_postgres_${terraform.workspace}"
    Environment = terraform.workspace
    Application = var.airflow_db_server_name
  }
}

data "aws_secretsmanager_secret" "by_name" {
  name = "etl/${terraform.workspace}"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.by_name.id
}
