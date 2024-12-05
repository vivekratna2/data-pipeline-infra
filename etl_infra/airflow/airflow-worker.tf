resource "aws_ecs_task_definition" "task_definition_airflow_worker" {
  family = "airflow_worker_app_${terraform.workspace}"
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
      app_secret                  = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["APP_SECRET"]
      redis_password              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PASSWORD"]
      airflow_username            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_USERNAME"]
      airflow_password            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AIRFLOW_PASSWORD"]
      mongodb_root_password       = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_ROOT_PASSWORD"]
      etl_version                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["ETL_VERSION"]
    }
  )
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "airflow_worker_app" {
  name                               = "airflow_worker_app_${terraform.workspace}"
  cluster                            = aws_ecs_cluster.ecs_cluster_worker_xl.id
  task_definition                    = aws_ecs_task_definition.task_definition_airflow_worker.arn
  launch_type                        = "EC2"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 0
  force_new_deployment               = true

  tags = {
    Environment = terraform.workspace
    Application = var.airflow_worker_app_name
  }
}