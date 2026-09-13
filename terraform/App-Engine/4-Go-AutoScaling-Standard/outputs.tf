output "service_url" {
  description = "Go Standard service URL"
  value       = "https://${var.service_name}-dot-${var.project_id}.ew.r.appspot.com"
}

output "version_url" {
  description = "Specific App Engine version URL"
  value       = "https://${var.version_id}-dot-${var.service_name}-dot-${var.project_id}.ew.r.appspot.com"
}

output "curl_service" {
  description = "Quick curl command"
  value       = "curl https://${var.service_name}-dot-${var.project_id}.ew.r.appspot.com"
}