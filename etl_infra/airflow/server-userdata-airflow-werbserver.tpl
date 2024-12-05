#!/bin/bash

  sudo su
  sudo yum -y update

  # Install and run docker
  sudo yum install -y docker amazon-ecr-credential-helper
  sudo service docker start
  sudo service docker status

  # Install docker compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
  sudo chmod +x /usr/bin/docker-compose
  echo "Installed Docker compose"

  sudo mkdir -p ~/.docker && chmod 0700 ~/.docker
  sudo echo '{"credsStore": "ecr-login"}' > ~/.docker/config.json

  # Save the docker-compose.yml
  echo "Saving docker compose.yml"
  echo "
  version: '3.7'
  services:
    airflow-webserver:
      image: 368759994472.dkr.ecr.us-west-2.amazonaws.com/airflow-data-pipeline-framework:${etl_version}
      command: webserver
      ports:
        - 8080:8080
      healthcheck:
        test: ["CMD", "curl", "--fail", "http://localhost:8080/health"]
        interval: 10s
        timeout: 10s
        retries: 5
      restart: always
      logging:
        driver: 'json-file'
        options:
          max-size: '100m'
          max-file: '2'
      environment:
        AIRFLOW__CORE__EXECUTOR: CeleryExecutor
        AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow@${postgres_host}/airflow
        AIRFLOW__CORE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow@${postgres_host}/airflow
        AIRFLOW__CELERY__RESULT_BACKEND: db+postgresql://airflow:airflow@${postgres_host}/airflow
        AIRFLOW__CELERY__BROKER_URL: redis://:${redis_password}@${redis_host}:6379/0
        AIRFLOW__CORE__FERNET_KEY: ''
        AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'false'
        AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
        AIRFLOW__CELERY__STALLED_TASK_TIMEOUT: 900
        AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT: 60
        AIRFLOW__API__AUTH_BACKENDS: airflow.api.auth.backend.basic_auth
        _AIRFLOW_WWW_USER_USERNAME: ${airflow_username}
        _AIRFLOW_WWW_USER_PASSWORD: ${airflow_password}
        AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER: s3://${s3_log_bucket}
        AIRFLOW__LOGGING__REMOTE_LOGGING: 'true'
        AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: s3://${s3_log_bucket}
        AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: etl_s3
        AIRFLOW_CONN_etl_S3: aws://${aws_access_key_rtaws}:${aws_secret_key_rtaws}@S3
        AIRFLOW__WEBSERVER__PAGE_SIZE: 15
        REDIS_DAG_HOST: ${redis_host}
        REDIS_DAG_PORT: 6379
        REDIS_DAG_DB_INDEX: 2
        REDIS_DAG_PASSWORD: ${redis_password}
        POSTGRES_HOST: ${postgres_host}
        POSTGRES_PORT: 5432
        _AIRFLOW_DB_UPGRADE: 'true'
        _AIRFLOW_WWW_USER_CREATE: 'true'
        _PIP_ADDITIONAL_REQUIREMENTS: ''
        ENVIRONMENT: ${environment}
        REGION: ${region}
        GBD_REDSHIFT_HOST: ${gbd_redshift_host}
        GBD_REDSHIFT_PORT: ${gbd_redshift_port}
        GBD_REDSHIFT_DB_NAME: ${gbd_redshift_db_name}
        GBD_REDSHIFT_USERNAME: ${gbd_redshift_username}
        GBD_REDSHIFT_PASSWORD: ${gbd_redshift_password}
        EC_REDSHIFT_HOST: ${ec_redshift_host}
        EC_REDSHIFT_PORT: ${ec_redshift_port}
        EC_REDSHIFT_DB_NAME: ${ec_redshift_db_name}
        EC_REDSHIFT_USERNAME: ${ec_redshift_username}
        EC_REDSHIFT_PASSWORD: ${ec_redshift_password}
        CACHE_SERVER_AUTHENTICATION: ${cache_server_authentication}
        DAF_V2_USERNAME: ${daf_v2_username}
        DAF_V2_PASSWORD: ${daf_v2_password}
        AWS_ACCESS_KEY_REDSHIFT: ${aws_access_key_redshift}
        AWS_SECRET_KEY_REDSHIFT: ${aws_secret_key_redshift}
        APP_SECRET: ${app_secret}
        REDIS_PASSWORD: ${redis_password}
        MONGODB_ROOT_PASSWORD: ${mongodb_root_password}
        AIRFLOW_ELB: ${airflow_elb}
        REDIS_HOST_CAI: ${redis_host_cai}
        REDIS_CAI_INDEX: ${redis_cai_index}
        DX_API_BEARER_TOKEN: ${dx_api_bearer_token}
  " > /home/ec2-user/docker-compose.yml
  echo "Saved docker compose"

  # Run the docker-compose.yml
  sudo docker-compose -f /home/ec2-user/docker-compose.yml up -d