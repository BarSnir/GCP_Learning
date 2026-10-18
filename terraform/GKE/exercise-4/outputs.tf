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
  value = google_container_cluster.gke.name
}

output "cluster_location" {
  value = google_container_cluster.gke.location
}

output "cluster_endpoint" {
  value = "https://${google_container_cluster.gke.endpoint}"
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --zone ${var.zone} --project ${var.project_id}"
}

output "system_node_pool" {
  value = google_container_node_pool.system.name
}

output "app_node_pool" {
  value = google_container_node_pool.apps.name
}

output "app_pool_min_nodes" {
  value = 0
}

output "app_pool_max_nodes" {
  value = 2
}

output "vpc_name" {
  value = google_compute_network.gke_vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.gke_subnet.name
}

output "node_cidr" {
  value = google_compute_subnetwork.gke_subnet.ip_cidr_range
}

output "pod_cidr" {
  value = "10.71.0.0/20"
}

output "service_cidr" {
  value = "10.72.0.0/24"
}

output "node_service_account" {
  value = google_service_account.gke_nodes.email
}