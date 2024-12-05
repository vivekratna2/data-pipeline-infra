# network interface
resource "aws_network_interface" "html-parser-webserver-interface" {
  subnet_id       = var.PRIVATE_SUBNET_ID
  private_ips     = [jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["PRIVATE_IP_WEBSERVER"]]
  security_groups = [aws_security_group.html_parser_sg.id]

  tags = {
    Name = "network_interface_for_html-parser-webserver"
  }
}

# instance for html-parser-webserver
resource "aws_instance" "html-parser-webserver" {
  ami           = var.EC2_AMI
  instance_type = var.EC2_INSTANCE_TYPE_WEB_SERVER
  key_name      = "html-parser-terraform"
  network_interface {
    network_interface_id = aws_network_interface.html-parser-webserver-interface.id
    device_index         = 0
  }
  tags = {
    Name    = "AWS-GBD-htmlparser_webserver_${terraform.workspace}"
    Project = "html_parser"
    Stage   = terraform.workspace
  }
  volume_tags = {
    Name = "htmlparser_webserver_volume_${terraform.workspace}"
  }
  # subnet_id              = var.PRIVATE_SUBNET_ID
  user_data = base64encode(templatefile("userdata/webserver_user_data.tftpl", {
    ENVIRONMENT              = terraform.workspace,
    RELEASE_VERSION          = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["RELEASE_VERSION"],
    ACCOUNT_ID               = data.aws_caller_identity.current.account_id,
    REDIS_RESULT_EXPIRE_DAYS = var.REDIS_RESULT_EXPIRE_DAYS,
    SCHEME_API_HOST          = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["SCHEME_API_HOST"],
    FLOWER_PORT              = var.FLOWER_PORT,
    REDIS_HOST               = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_HOST"],
    REDIS_PORT               = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PORT"],
    REDIS_DB                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DB"],
    REDIS_DB_SCHEME_CACHE    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DB_SCHEME_CACHE"],
    FLASK_PORT               = var.FLASK_PORT,
    MONGODB_USERNAME         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_USERNAME"],
    MONGODB_PASSWORD         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_PASSWORD"],
    MONGODB_PORT             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_PORT"],
    US_IP                    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["US_IP"],
    CA_IP                    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CA_IP"],
    DEV_IP                   = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DEV_IP"]
    POSTGRES_HOST            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_HOST"],
    POSTGRES_PORT            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_PORT"],
    POSTGRES_USER            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_USER"],
    POSTGRES_PASSWORD        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_PASSWORD"],
    POSTGRES_DB              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_DB"],
    US_TOKEN                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["US_TOKEN"],
    DEV_TOKEN                = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DEV_TOKEN"],
    etl_API_GATEWAY_URL      = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_GATEWAY_URL"],
    etl_API_KEY              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_KEY"],
    REDIS_DB_SCHEME_CACHE    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DB_SCHEME_CACHE"],
  }))

  iam_instance_profile = aws_iam_instance_profile.ec2_ecr_profile.name
}
