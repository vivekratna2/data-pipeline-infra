output "etl_api_server_private_ip" {
  value = aws_instance.flask_api_instance.private_ip
}

output "etl_api_server_public_ip" {
  value = aws_instance.flask_api_instance.public_ip
}