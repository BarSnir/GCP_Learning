output "service_url" {
  value = "https://${var.service_name}-dot-${var.project_id}.ew.r.appspot.com"
}

output "version_url" {
  value = "https://${var.version_id}-dot-${var.service_name}-dot-${var.project_id}.ew.r.appspot.com"
}

output "curl_service" {
  value = "curl https://${var.service_name}-dot-${var.project_id}.ew.r.appspot.com"
}