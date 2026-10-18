output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = data.google_project.current.number
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

output "node_pool_name" {
  value = google_container_node_pool.primary.name
}

output "node_service_account" {
  value = google_service_account.gke_nodes.email
}

output "workload_identity_pool" {
  value = "${var.project_id}.svc.id.goog"
}

output "workload_identity_principal" {
  value = local.workload_identity_principal
}

output "workload_namespace" {
  value = var.workload_namespace
}

output "kubernetes_service_account" {
  value = var.kubernetes_service_account
}

output "bucket_name" {
  value = google_storage_bucket.demo.name
}

output "demo_object_uri" {
  value = "gs://${google_storage_bucket.demo.name}/${google_storage_bucket_object.demo_file.name}"
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
  value = "10.81.0.0/20"
}

output "service_cidr" {
  value = "10.82.0.0/24"
}