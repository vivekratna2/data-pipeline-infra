output "htmlparser_flower_private_ip" {
  value       = aws_network_interface.html-parser-flower-interface.private_ips
  sensitive   = true
  description = "Private IP of Html Parser Flower"
}

output "htmlparser_webserver_private_ip" {
  value       = aws_network_interface.html-parser-webserver-interface.private_ips
  sensitive   = true
  description = "Private IP of Html Parser Webserver"
}