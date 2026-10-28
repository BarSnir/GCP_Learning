output "project_id" {
  description = "Fleet Host Project"
  value       = var.project_id
}

output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.fleet.name
}

output "gke_membership_name" {
  description = "GKE Fleet membership"
  value       = google_gke_hub_membership.gke.membership_id
}

output "external_k8s_vm_name" {
  description = "External Kubernetes VM"
  value       = google_compute_instance.external_k8s.name
}

output "external_k8s_internal_ip" {
  description = "External Kubernetes internal IP"
  value       = google_compute_instance.external_k8s.network_interface[0].network_ip
}

output "external_membership_name" {
  description = "External Kubernetes Fleet membership"
  value       = var.external_membership_name
}

output "verify_command" {
  description = "Verify both Fleet members through Connect Gateway"
  value       = "./scripts/verify.sh"
}
