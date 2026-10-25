output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "cluster_zone" {
  value = google_container_cluster.gke.location
}

output "vpc_name" {
  value = google_compute_network.gke_vpc.name
}

output "node_service_account" {
  value = google_service_account.gke_nodes.email
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --zone ${var.zone} --project ${var.project_id}"
}