output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "repository_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}"
}

output "image_uri" {
  description = "Current container image URI"
  value       = local.image_uri
}

output "service_account" {
  description = "Cloud Run runtime service account"
  value       = google_service_account.runtime.email
}

output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.api.uri
}

output "latest_created_revision" {
  description = "Latest created revision"
  value       = google_cloud_run_v2_service.api.latest_created_revision
}

output "latest_ready_revision" {
  description = "Latest ready revision"
  value       = google_cloud_run_v2_service.api.latest_ready_revision
}