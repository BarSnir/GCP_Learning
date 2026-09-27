output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}"
}

output "image_uri" {
  value = local.image_uri
}

output "cloud_run_url" {
  value = google_cloud_run_v2_service.api.uri
}

output "latest_revision" {
  value = google_cloud_run_v2_service.api.latest_ready_revision
}

output "cpu" {
  value = var.cpu
}

output "memory" {
  value = var.memory
}

output "container_concurrency" {
  value = var.container_concurrency
}

output "max_instances" {
  value = var.max_instances
}

output "billing_mode" {
  value = "instance-based"
}