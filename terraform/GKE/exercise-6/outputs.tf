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

output "node_pool_name" {
  value = google_container_node_pool.primary.name
}

output "node_count" {
  value = var.node_count
}

output "node_service_account" {
  value = google_service_account.gke_nodes.email
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
  value = "10.91.0.0/20"
}

output "service_cidr" {
  value = "10.92.0.0/24"
}

output "logging_components" {
  value = [
    "SYSTEM_COMPONENTS",
    "WORKLOADS"
  ]
}

output "managed_prometheus_enabled" {
  value = true
}

output "managed_opentelemetry_enabled" {
  value = true
}

output "managed_otlp_endpoint" {
  value = "http://opentelemetry-collector.gke-managed-otel.svc.cluster.local:4318"
}

output "pubsub_topic" {
  value = google_pubsub_topic.gke_logs.name
}

output "pubsub_subscription" {
  value = google_pubsub_subscription.gke_logs.name
}

output "logging_sink" {
  value = google_logging_project_sink.gke_logs.name
}

output "alert_policy_name" {
  value = google_monitoring_alert_policy.gke_error_log.display_name
}