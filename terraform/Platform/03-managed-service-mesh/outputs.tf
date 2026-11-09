output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "zone" {
  description = "GCP zone"
  value       = var.zone
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.mesh.name
}

output "membership_name" {
  description = "Fleet membership name"
  value       = google_gke_hub_membership.mesh.membership_id
}

output "credentials_command" {
  description = "Get GKE credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.mesh.name} --zone ${var.zone} --project ${var.project_id}"
}

output "mesh_status_command" {
  description = "Check managed Cloud Service Mesh status"
  value       = "gcloud container fleet mesh describe --project=${var.project_id}"
}
