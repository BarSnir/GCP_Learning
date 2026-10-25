output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = data.google_project.current.number
}

output "vpc_name" {
  value = google_compute_network.gke_vpc.name
}

output "clusters" {
  value = {
    for key, cluster in google_container_cluster.gke :
    key => {
      name       = cluster.name
      region     = cluster.location
      node_zone  = local.clusters[key].node_zone
      endpoint   = cluster.endpoint
      membership = google_gke_hub_membership.membership[key].membership_id
    }
  }
}

output "get_credentials_commands" {
  value = {
    for key, cluster in google_container_cluster.gke :
    key => "gcloud container clusters get-credentials ${cluster.name} --region ${cluster.location} --project ${var.project_id}"
  }
}

output "node_count_per_cluster" {
  value = var.node_count
}

output "mcs_feature" {
  value = google_gke_hub_feature.mcs.name
}

output "multi_cluster_gateway_feature" {
  value = google_gke_hub_feature.multi_cluster_gateway.name
}

output "config_membership" {
  value = google_gke_hub_membership.membership["west1"].id
}