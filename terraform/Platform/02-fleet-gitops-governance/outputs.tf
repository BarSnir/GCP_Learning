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

output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.gitops.name
}

output "membership_name" {
  description = "Fleet membership name"
  value       = google_gke_hub_membership.gitops.membership_id
}

output "config_sync_repo" {
  description = "Git repository used by Config Sync"
  value       = var.git_repo
}

output "config_sync_policy_dir" {
  description = "Git directory synchronized by Config Sync"
  value       = var.policy_dir
}

output "gke_credentials_command" {
  description = "Get GKE credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gitops.name} --zone ${var.zone} --project ${var.project_id}"
}

output "verify_command" {
  description = "Verify Fleet, Config Sync, and Policy Controller"
  value       = "./scripts/verify.sh"
}
