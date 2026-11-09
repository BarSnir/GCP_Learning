output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "cluster_name" {
  value = google_container_cluster.mesh.name
}

output "membership_name" {
  value = google_gke_hub_membership.mesh.membership_id
}

output "credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.mesh.name} --zone ${var.zone} --project ${var.project_id}"
}

output "mesh_status_command" {
  value = "gcloud container fleet mesh describe --project=${var.project_id}"
}
