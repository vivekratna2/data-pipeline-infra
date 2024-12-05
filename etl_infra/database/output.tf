output "airflow_postgres_server_ip" {
  value = aws_instance.db_instance.private_ip
}

output "airflow_mongodb_server_ip" {
  value = aws_instance.mongodb_instance.private_ip
}

output "etl_cai_reparse_queue_url" {
  value = aws_sqs_queue.cai_reparse_sqs.url
}