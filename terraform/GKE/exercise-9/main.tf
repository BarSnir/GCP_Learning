terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

data "google_project" "current" {
  project_id = var.project_id
}

locals {
  clusters = {
    west1 = {
      name         = "gke-ex9-west1"
      region       = "europe-west1"
      node_zone    = "europe-west1-b"
      subnet_cidr  = "10.120.0.0/24"
      pod_cidr     = "10.121.0.0/20"
      service_cidr = "10.122.0.0/24"
    }

    west4 = {
      name         = "gke-ex9-west4"
      region       = "europe-west4"
      node_zone    = "europe-west4-a"
      subnet_cidr  = "10.123.0.0/24"
      pod_cidr     = "10.124.0.0/20"
      service_cidr = "10.125.0.0/24"
    }
  }

  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "gkehub.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "multiclusteringress.googleapis.com",
    "trafficdirector.googleapis.com",
    "dns.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "connectgateway.googleapis.com"
  ])
}

#
# APIs
#

resource "google_project_service" "required_apis" {
  for_each = local.required_apis

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

#
# Shared VPC
#

resource "google_compute_network" "gke_vpc" {
  name                    = "gke-ex9-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

#
# Regional subnets
#

resource "google_compute_subnetwork" "gke_subnet" {
  for_each = local.clusters

  name          = "gke-ex9-${each.key}-subnet"
  region        = each.value.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = each.value.subnet_cidr

  secondary_ip_range {
    range_name    = "gke-ex9-${each.key}-pods"
    ip_cidr_range = each.value.pod_cidr
  }

  secondary_ip_range {
    range_name    = "gke-ex9-${each.key}-services"
    ip_cidr_range = each.value.service_cidr
  }
}

#
# Node Service Account
#

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ex9-node-sa"
  display_name = "GKE Exercise 9 Node Service Account"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_project_iam_member" "gke_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"

  member = "serviceAccount:${google_service_account.gke_nodes.email}"
}

#
# Regional GKE clusters
#

resource "google_container_cluster" "gke" {
  for_each = local.clusters

  name     = each.value.name
  location = each.value.region

  node_locations = [
    each.value.node_zone
  ]

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet[each.key].id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex9-${each.key}-pods"
    services_secondary_range_name = "gke-ex9-${each.key}-services"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  logging_service    = "none"
  monitoring_service = "none"

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_service.required_apis
  ]
}

#
# One worker per cluster
#

resource "google_container_node_pool" "primary" {
  for_each = local.clusters

  name     = "gke-ex9-${each.key}-pool"
  location = each.value.region
  cluster  = google_container_cluster.gke[each.key].name

  node_count = var.node_count

  node_locations = [
    each.value.node_zone
  ]

  node_config {
    machine_type = "e2-small"

    disk_type    = "pd-standard"
    disk_size_gb = 20

    image_type = "COS_CONTAINERD"

    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      environment = "lab"
      exercise    = "ex9"
      cluster     = each.key
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_project_iam_member.gke_node_role
  ]
}

#
# Fleet memberships
#

resource "google_gke_hub_membership" "membership" {
  for_each = local.clusters

  membership_id = each.value.name
  location      = each.value.region

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.gke[each.key].id}"
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_container_node_pool.primary
  ]
}

#
# Multi-Cluster Services
#

resource "google_gke_hub_feature" "mcs" {
  name     = "multiclusterservicediscovery"
  location = "global"
  project  = var.project_id

  depends_on = [
    google_gke_hub_membership.membership
  ]
}

#
# MCS importer permissions
#

resource "google_project_iam_member" "mcs_network_viewer" {
  project = var.project_id
  role    = "roles/compute.networkViewer"

  member = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/gke-mcs/sa/gke-mcs-importer"

  depends_on = [
    google_gke_hub_feature.mcs
  ]
}

#
# MCS Google-managed service agent
#

resource "google_project_iam_member" "mcs_service_agent" {
  project = var.project_id
  role    = "roles/multiclusterservicediscovery.serviceAgent"

  member = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-mcsd.iam.gserviceaccount.com"

  depends_on = [
    google_gke_hub_feature.mcs
  ]
}

#
# Multi-Cluster Gateway
#
# west1 is our config cluster.
#

resource "google_gke_hub_feature" "multi_cluster_gateway" {
  name     = "multiclusteringress"
  location = "global"
  project  = var.project_id

  spec {
    multiclusteringress {
      config_membership = google_gke_hub_membership.membership["west1"].id
    }
  }

  depends_on = [
    google_gke_hub_feature.mcs,
    google_project_iam_member.mcs_network_viewer,
    google_project_iam_member.mcs_service_agent
  ]
}

#
# Multi-Cluster Gateway controller permissions
#

resource "google_project_iam_member" "multi_cluster_gateway_admin" {
  project = var.project_id
  role    = "roles/container.admin"

  member = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-multiclusteringress.iam.gserviceaccount.com"

  depends_on = [
    google_gke_hub_feature.multi_cluster_gateway
  ]
}