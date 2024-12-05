[
  {
      "name": "airflow_worker_app",
      "image": "368759994472.dkr.ecr.us-west-2.amazonaws.com/airflow-data-pipeline-framework:${etl_version}",
      "essential": true,
      "portMappings": [
          {
              "hostPort": 8793,
              "protocol": "tcp",
              "containerPort": 8793
          }
      ],
      "requires_compatibilities": ["EC2"],
      "memory": 15000,
      "command": ["celery", "worker", "-q", "reparse"],
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
              "name": "_PIP_ADDITIONAL_REQUIREMENTS",
              "value": ""
          },
          {
              "name": "AIRFLOW_CONN_MONGO_DEFAULT",
              "value": "mongodb://db_user:${mongodb_root_password}@${mongodb_host}/?retryWrites=true&w=majority"
          },
          {
              "name": "MONGO_INITDB_ROOT_USERNAME",
              "value": "db_user"
          },
          {
              "name": "MONGO_INITDB_ROOT_PASSWORD",
              "value": "${mongodb_root_password}"
          },
          {
              "name": "MONGODB_HOST",
              "value": "${mongodb_host}"
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
            "name":"GBD_REDSHIFT_HOST",
            "value":"${gbd_redshift_host}"
          },
          {
            "name":"GBD_REDSHIFT_PORT",
            "value":"${gbd_redshift_port}"
          },
          {
            "name":"GBD_REDSHIFT_DB_NAME",
            "value":"${gbd_redshift_db_name}"
          },
          {
            "name":"GBD_REDSHIFT_USERNAME",
            "value":"${gbd_redshift_username}"
          },
          {
            "name":"GBD_REDSHIFT_PASSWORD",
            "value":"${gbd_redshift_password}"
          },
          {
            "name":"EC_REDSHIFT_HOST",
            "value":"${ec_redshift_host}"
          },
          {
            "name":"EC_REDSHIFT_PORT",
            "value":"${ec_redshift_port}"
          },
          {
            "name":"EC_REDSHIFT_DB_NAME",
            "value":"${ec_redshift_db_name}"
          },
          {
            "name":"EC_REDSHIFT_USERNAME",
            "value":"${ec_redshift_username}"
          },
          {
            "name":"EC_REDSHIFT_PASSWORD",
            "value":"${ec_redshift_password}"
          },
          {
            "name":"CACHE_SERVER_AUTHENTICATION",
            "value":"${cache_server_authentication}"
          },
          {
            "name":"DAF_V2_USERNAME",
            "value":"${daf_v2_username}"
          },
          {
            "name":"DAF_V2_PASSWORD",
            "value":"${daf_v2_password}"
          },
          {
            "name":"AWS_ACCESS_KEY_REDSHIFT",
            "value":"${aws_access_key_redshift}"
          },
          {
            "name":"AWS_SECRET_KEY_REDSHIFT",
            "value":"${aws_secret_key_redshift}"
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
          },
          {
            "name":"AIRFLOW_ELB",
            "value":"${airflow_elb}"
          },
          {
            "name":"REDIS_HOST_CAI",
            "value":"${redis_host_cai}"
          },
          {
            "name":"REDIS_CAI_INDEX",
            "value":"${redis_cai_index}"
          },
          {
            "name":"DX_API_BEARER_TOKEN",
            "value":"${dx_api_bearer_token}"
          },
          {
            "name":"AIRFLOW__CELERY__WORKER_CONCURRENCY",
            "value":"4"
          },
          {
            "name":"CAI_LOGIN_EMAIL_DAF_V2",
            "value":"${cai_login_email_daf_v2}"
          },
          {
            "name":"AIRFLOW__LOGGING__DELETE_LOCAL_LOGS",
            "value":"True"
          },
          {
            "name":"etl_API_IP",
            "value":"${etl_api_ip}"
          },
          {
            "name":"etl_API_AUTH_TOKEN",
            "value":"${etl_api_auth_token}"
          },
          {
            "name":"CAI_REDSHIFT_PASSWORD",
            "value":"${cai_redshift_password}"
          },
          {
            "name":"CAI_REDSHIFT_USER",
            "value":"${cai_redshift_user}"
          },
          {
            "name":"CAI_REDSHIFT_HOST",
            "value":"${cai_redshift_host}"
          },
          {
            "name":"CAI_REDSHFIT_DB",
            "value":"${cai_redshift_db}"
          },
          {
            "name":"HTML_PARSER_PUBLIC_IP",
            "value":"${html_parser_public_ip}"
          },
          {
            "name":"etl_API_IP_PUBLIC",
            "value":"${etl_api_ip_public}"
          },
          {
            "name":"CAI_REPARSE_SQS_QUEUE_URL",
            "value":"${cai_reparse_sqs_queue_url}"
          },
          {
            "name":"DX_BASE_URL",
            "value":"${dx_base_url}"
          },
          {
            "name":"DX_TOKEN",
            "value":"${dx_token}"
          },
          {
            "name":"DAF_API_GATEWAY_URL",
            "value":"${daf_api_gateway_url}"
          }
      ]
  }
]