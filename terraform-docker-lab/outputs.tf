output "url" {
  description = "Loopback URL served by the lab."
  value       = "http://127.0.0.1:${var.host_port}"
}

output "container_name" {
  description = "Docker container name derived from lab_name."
  value       = docker_container.web.name
}
