resource "aws_instance" "webserver_instance" {
  ami                         = "ami-098e42ae54c764c35"
  associate_public_ip_address = true
  instance_type               = "m5a.large"
  key_name                    = "etl-us-west-2"
  vpc_security_group_ids      = [aws_security_group.etl_webserver_sg.id]
  user_data = templatefile(
    "${path.module}/server-userdata-airflow-werbserver.tpl",
    {
      postgres_host               = data.terraform_remote_state.airflow_db_output.outputs.airflow_postgres_server_ip
      redis_host                  = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_HOST"]
      redis_airflow_index         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_AIRFLOW_INDEX"]
      redis_dag_index             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DAG_INDEX"]
      mongodb_host                = data.terraform_remote_state.airflow_db_output.outputs.airflow_mongodb_server_ip
      s3_log_bucket               = var.s3_log_bucket
      region                      = var.region
      environment                 = terraform.workspace
      app_secret                  = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["APP_SECRET"]
      redis_password              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PASSWORD"]
      airflow_username            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_USERNAME"]
      airflow_password            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_PASSWORD"]
      mongodb_root_password       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_ROOT_PASSWORD"]
      etl_version                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["ETL_VERSION"]
    }
  )
  subnet_id            = var.public_subnet_id_1
  iam_instance_profile = aws_iam_instance_profile.etl_webserver_profile.name

  tags = {
    Name        = "etl_webserver_${terraform.workspace}"
    Environment = terraform.workspace
    Application = "webserver"
  }
}

data "aws_eip" "by_tags" {
  tags = {
    Name = "gbd_data_platform_webserver_${terraform.workspace}"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.webserver_instance.id
  allocation_id = data.aws_eip.by_tags.id
}

resource "aws_iam_instance_profile" "etl_webserver_profile" {
  name = "etl_webserver_profile_${terraform.workspace}"
  role = aws_iam_role.etl_webserver_role.name
}

resource "aws_iam_role" "etl_webserver_role" {
  name               = "etl_webserver_role_${terraform.workspace}"
  assume_role_policy = <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Principal": {
                 "Service": "ec2.amazonaws.com"
              },
              "Effect": "Allow",
              "Sid": ""
          }
      ]
  }
  EOF

  inline_policy {
    name = "etl_app_inline_policy_ec2"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:DescribeTags",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "etl_app_inline_policy_s3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:*",
            "secretsmanager:GetRandomPassword",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:ListSecrets"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}
