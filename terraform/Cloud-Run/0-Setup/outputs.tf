output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "Default GCP region"
  value       = var.region
}

output "enabled_apis" {
  description = "APIs managed by Terraform"
  value       = keys(google_project_service.required_apis)
}

output "cloud_run_service_account" {
  description = "Cloud Run runtime Service Account"
  value       = google_service_account.cloud_run_runtime.email
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository"
  value       = google_artifact_registry_repository.cloud_run_repo.name
}

output "artifact_registry_url" {
  description = "Artifact Registry Docker repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repository_name}"
}

output "image_uri" {
  description = "Full container image URI"
  value       = local.image_uri
}

output "cloud_run_url" {
  description = "Cloud Run Service URL"
  value       = google_cloud_run_v2_service.app.uri
}

output "latest_created_revision" {
  description = "Latest created Cloud Run revision"
  value       = google_cloud_run_v2_service.app.latest_created_revision
}

output "latest_ready_revision" {
  description = "Latest ready Cloud Run revision"
  value       = google_cloud_run_v2_service.app.latest_ready_revision
}