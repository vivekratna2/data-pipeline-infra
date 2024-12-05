[

  {
      "name": "airflow_webserver_app",
      "image": "xxxxx.dkr.ecr.us-west-2.amazonaws.com/airflow-data-pipeline-framework:${etl_version}",
      "essential": true,
      "portMappings": [
          {
              "hostPort": 8080,
              "protocol": "tcp",
              "containerPort": 8080
          }
      ],
      "requires_compatibilities": ["EC2"],
      "memory": 7500,
      "command": ["webserver"],
      "LogConfiguration": {
          "LogDriver": "json-file",
          "Options": {
              "max-size": "500m",
              "max-file": "2"
          }
      },
      "environment": [
          {
              "name": "AIRFLOW__CORE__EXECUTOR",
              "value": "CeleryExecutor"
          },
          {
              "name": "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN",
              "value": "postgresql+psycopg2://airflow:airflow@${postgres_host}/airflow"
          },
          {
              "name": "AIRFLOW__CORE__SQL_ALCHEMY_CONN",
              "value": "postgresql+psycopg2://airflow:airflow@${postgres_host}/airflow"
          },
          {
              "name": "AIRFLOW__CELERY__RESULT_BACKEND",
              "value": "db+postgresql://airflow:airflow@${postgres_host}/airflow"
          },
          {
              "name": "AIRFLOW__CELERY__BROKER_URL",
              "value": "redis://:@${redis_host}:6379/${redis_airflow_index}"
          },
          {
              "name": "AIRFLOW__CORE__FERNET_KEY",
              "value": ""
          },
          {
              "name": "AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION",
              "value": "false"
          },
          {
              "name": "AIRFLOW__CORE__LOAD_EXAMPLES",
              "value": "false"
          },
          {
              "name": "AIRFLOW__CELERY__STALLED_TASK_TIMEOUT",
              "value": "900"
          },
          {
              "name": "AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT",
              "value": "60"
          },
          {
              "name": "AIRFLOW__API__AUTH_BACKENDS",
              "value": "airflow.api.auth.backend.basic_auth"
          },
          {
              "name": "_AIRFLOW_WWW_USER_USERNAME",
              "value": "${airflow_username}"
          },
          {
              "name": "_AIRFLOW_WWW_USER_PASSWORD",
              "value": "${airflow_password}"
          },
          {
              "name": "AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER",
              "value": "s3://${s3_log_bucket}"
          },
          {
              "name": "AIRFLOW__LOGGING__REMOTE_LOGGING",
              "value": "True"
          },
          {
              "name": "AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER",
              "value": "s3://${s3_log_bucket}"
          },
          {
              "name": "AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID",
              "value": "etl_s3"
          },
          {
              "name": "AIRFLOW_CONN_etl_S3",
              "value": ""
          },
          {
              "name": "AIRFLOW__WEBSERVER__PAGE_SIZE",
              "value": "15"
          },
          {
              "name": "REDIS_DAG_HOST",
              "value": "${redis_host}"
          },
          {
              "name": "REDIS_DAG_PORT",
              "value": "6379"
          },
          {
              "name": "REDIS_DAG_DB_INDEX",
              "value": "${redis_dag_index}"
          },
          {
              "name": "REDIS_DAG_PASSWORD",
              "value": ""
          },
          {
              "name": "POSTGRES_HOST",
              "value": "${postgres_host}"
          },
          {
              "name": "POSTGRES_PORT",
              "value": "5432"
          },
          {
              "name": "_AIRFLOW_DB_UPGRADE",
              "value": "true"
          },
          {
              "name": "_AIRFLOW_WWW_USER_CREATE",
              "value": "true"
          },
          {
              "name": "_PIP_ADDITIONAL_REQUIREMENTS",
              "value": ""
          },
          {
              "name": "ENVIRONMENT",
              "value": "${environment}"
          },
          {
              "name": "REGION",
              "value": "${region}"
          },
          {
            "name":"APP_SECRET",
            "value":"${app_secret}"
          },
          {
            "name":"REDIS_PASSWORD",
            "value":""
          },
          {
            "name":"MONGODB_ROOT_PASSWORD",
            "value":"${mongodb_root_password}"
          }
      ]
  }
]