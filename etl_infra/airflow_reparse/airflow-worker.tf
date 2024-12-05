resource "aws_ecs_task_definition" "task_definition_airflow_worker_reparse" {
  family = "airflow_worker_reparse_app_${terraform.workspace}"
  container_definitions = templatefile(
    "${path.module}/task-definitions/airflow-worker.json.tpl",
    {
      postgres_host               = data.terraform_remote_state.airflow_db_output.outputs.airflow_postgres_server_ip
      redis_host                  = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_HOST"]
      redis_airflow_index         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_AIRFLOW_INDEX"]
      redis_dag_index             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DAG_INDEX"]
      mongodb_host                = data.terraform_remote_state.airflow_db_output.outputs.airflow_mongodb_server_ip
      redis_password              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PASSWORD"]
      s3_log_bucket               = var.s3_log_bucket
      region                      = var.region
      environment                 = terraform.workspace
      gbd_redshift_host           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["GBD_REDSHIFT_HOST"]
      gbd_redshift_port           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["GBD_REDSHIFT_PORT"]
      gbd_redshift_db_name        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["GBD_REDSHIFT_DB_NAME"]
      gbd_redshift_username       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["GBD_REDSHIFT_USERNAME"]
      gbd_redshift_password       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["GBD_REDSHIFT_PASSWORD"]
      ec_redshift_host            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["EC_REDSHIFT_HOST"]
      ec_redshift_port            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["EC_REDSHIFT_PORT"]
      ec_redshift_db_name         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["EC_REDSHIFT_DB_NAME"]
      ec_redshift_username        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["EC_REDSHIFT_USERNAME"]
      ec_redshift_password        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["EC_REDSHIFT_PASSWORD"]
      cache_server_authentication = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CACHE_SERVER_AUTHENTICATION"]
      daf_v2_username             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DAF_V2_USERNAME"]
      daf_v2_password             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DAF_V2_PASSWORD"]
      aws_access_key_redshift     = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_ACCESS_KEY_REDSHIFT"]
      aws_secret_key_redshift     = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_SECRET_KEY_REDSHIFT"]
      app_secret                  = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["APP_SECRET"]
      redis_password              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PASSWORD"]
      airflow_username            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_USERNAME"]
      airflow_password            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_PASSWORD"]
      mongodb_root_password       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_ROOT_PASSWORD"]
      etl_version                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_VERSION"]
      aws_access_key_rtaws        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_ACCESS_KEY_RTAWS"]
      aws_secret_key_rtaws        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_SECRET_KEY_RTAWS"]
      airflow_elb                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_ELB"]
      redis_host_cai              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_HOST"]
      redis_cai_index             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_CAI_INDEX"]
      dx_api_bearer_token         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DX_API_BEARER_TOKEN"]
      cai_login_email_daf_v2      = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CAI_LOGIN_EMAIL_DAF_V2"]
      etl_api_ip                  = data.terraform_remote_state.etl_api_output.outputs.etl_api_server_private_ip
      etl_api_auth_token          = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_AUTH_TOKEN"]
      cai_redshift_password       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CAI_REDSHIFT_PASSWORD"]
      cai_redshift_user           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CAI_REDSHIFT_USER"]
      cai_redshift_host           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CAI_REDSHIFT_HOST"]
      cai_redshift_db             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CAI_REDSHFIT_DB"]
      html_parser_public_ip       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["HTML_PARSER_PUBLIC_IP"]
      etl_api_ip_public           = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_IP_PUBLIC"]
      cai_reparse_sqs_queue_url   = data.terraform_remote_state.airflow_db_output.outputs.etl_cai_reparse_queue_url
      dx_base_url                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DX_BASE_URL"]
      dx_token                    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DX_TOKEN"]
      daf_api_gateway_url         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DAF_API_GATEWAY_URL"]
    }
  )
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "airflow_worker_reparse_app" {
  name                               = "airflow_worker_reparse_app_${terraform.workspace}"
  cluster                            = aws_ecs_cluster.ecs_cluster_worker_reparse.id
  task_definition                    = aws_ecs_task_definition.task_definition_airflow_worker_reparse.arn
  launch_type                        = "EC2"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 0
  force_new_deployment               = true

  tags = {
    Environment = terraform.workspace
    Application = var.airflow_worker_app_name
  }
}