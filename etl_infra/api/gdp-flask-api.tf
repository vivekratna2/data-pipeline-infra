resource "aws_instance" "flask_api_instance" {
  ami                         = "ami-098e42ae54c764c35"
  associate_public_ip_address = true
  instance_type               = "t3a.small"
  key_name                    = "etl-us-west-2"
  vpc_security_group_ids      = [aws_security_group.etl_api_security_group.id]
  subnet_id                   = var.public_subnet_id
  iam_instance_profile        = aws_iam_instance_profile.etl_flask_api_profile.name
  user_data = templatefile(
    "${path.module}/server-userdata.tpl",
    {
      redis_host                = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_HOST"]
      redis_dag_index           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DAG_INDEX"]
      etl_api_version           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_VERSION"]
      dx_base_url               = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DX_BASE_URL"]
      dx_token                  = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DX_TOKEN"]
      environment               = terraform.workspace
      cai_reparse_sqs_queue_url = data.terraform_remote_state.etl_db_output.outputs.etl_cai_reparse_queue_url
    }
  )

  tags = {
    Name        = "etl_flask_api_${terraform.workspace}"
    Environment = terraform.workspace
  }
}

data "aws_eip" "by_tags" {
  tags = {
    Name = "gbd_data_platform_api_server_${terraform.workspace}"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.flask_api_instance.id
  allocation_id = data.aws_eip.by_tags.id
}

resource "aws_iam_instance_profile" "etl_flask_api_profile" {
  name = "etl_flask_api_profile_${terraform.workspace}"
  role = aws_iam_role.etl_flask_api_role.name
}

resource "aws_iam_role" "etl_flask_api_role" {
  name               = "etl_flask_api_role_${terraform.workspace}"
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
            "logs:PutLogEvents",
            "sqs:*"
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
