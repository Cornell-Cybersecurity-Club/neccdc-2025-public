output "database_ip" {
  value       = aws_instance.database.private_ip
  description = "The private IP address of the database instance"
}

output "nginx_ip" {
  value       = aws_instance.nginx.private_ip
  description = "The private IP address of the nginx instance"
}
