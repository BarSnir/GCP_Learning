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

output "job_name" {
  value = google_cloud_run_v2_job.batch.name
}

output "service_account" {
  value = google_service_account.runtime.email
}

output "task_count" {
  value = var.task_count
}

output "parallelism" {
  value = var.parallelism
}