resource "aws_instance" "mongodb_instance" {
  ami                         = "ami-098e42ae54c764c35"
  associate_public_ip_address = true
  instance_type               = "m5a.large"
  key_name                    = "etl-us-west-2"
  vpc_security_group_ids      = [aws_security_group.etl_mongodb_security_group.id]
  user_data = templatefile(
    "${path.module}/server-userdata-mongodb.tpl",
    {
      mongodb_root_password = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_ROOT_PASSWORD"]
    }
  )
  subnet_id = data.terraform_remote_state.etl_vpc.outputs.public_subnet_ip_1

  root_block_device {
    volume_size           = "32"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name        = "etl_mongodb_${terraform.workspace}"
    Environment = terraform.workspace
    Application = var.airflow_db_server_name
  }
}