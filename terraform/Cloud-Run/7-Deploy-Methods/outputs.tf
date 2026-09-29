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
  value = google_cloud_run_v2_service.image_service.uri
}

output "latest_revision" {
  value = google_cloud_run_v2_service.image_service.latest_ready_revision
}

output "deployment_method" {
  value = "prebuilt-container-image"
}