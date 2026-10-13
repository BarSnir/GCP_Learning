output "project_id" {
  description = "GCP project used by this exercise"
  value       = var.project_id
}

output "region" {
  description = "Default GCP region"
  value       = var.region
}

output "zone" {
  description = "GCP zone used for the zonal GKE cluster"
  value       = var.zone
}

output "enabled_apis" {
  description = "APIs required for the GKE exercises"
  value       = sort(tolist(local.required_apis))
}

output "vpc_name" {
  description = "Custom VPC used by GKE"
  value       = google_compute_network.gke_vpc.name
}

output "subnet_name" {
  description = "Subnet used by GKE"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "node_cidr" {
  value = google_compute_subnetwork.gke_subnet.ip_cidr_range
}

output "pod_cidr" {
  value = "10.20.0.0/20"
}

output "service_cidr" {
  value = "10.30.0.0/24"
}

output "gke_node_service_account" {
  description = "Service account used by GKE worker nodes"
  value       = google_service_account.gke_nodes.email
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.gke.name
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.gke.location
}

output "cluster_endpoint" {
  description = "GKE Kubernetes API endpoint"
  value       = "https://${google_container_cluster.gke.endpoint}"
}

output "get_credentials_command" {
  description = "Command used to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --zone ${var.zone} --project ${var.project_id}"
}

output "node_pool_name" {
  description = "Primary GKE node pool"
  value       = google_container_node_pool.primary.name
}

output "node_count" {
  description = "Current desired number of lab worker nodes"
  value       = var.node_count
}

output "node_machine_type" {
  description = "Machine type used by the lab node"
  value       = "e2-small"
}

output "artifact_registry_repository" {
  description = "Artifact Registry Docker repository"
  value       = google_artifact_registry_repository.gke_repo.name
}

output "artifact_registry_url" {
  description = "Artifact Registry Docker URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.gke_repo.repository_id}"
}