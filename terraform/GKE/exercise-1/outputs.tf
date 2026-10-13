output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
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
  value = "10.41.0.0/20"
}

output "service_cidr" {
  value = "10.42.0.0/24"
}

output "standard_node_service_account" {
  value = google_service_account.standard_nodes.email
}

output "standard_cluster_name" {
  value = google_container_cluster.standard.name
}

output "standard_cluster_location" {
  value = google_container_cluster.standard.location
}

output "standard_get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.standard.name} --zone ${var.zone} --project ${var.project_id}"
}

output "autopilot_cluster_name" {
  value = google_container_cluster.autopilot.name
}

output "autopilot_cluster_location" {
  value = google_container_cluster.autopilot.location
}

output "autopilot_get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.autopilot.name} --region ${var.region} --project ${var.project_id}"
}