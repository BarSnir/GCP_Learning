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
  region  = var.region
  zone    = var.zone
}

# ---------------------------------------------------------
# APIs
# ---------------------------------------------------------

locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "mesh.googleapis.com",
    "meshconfig.googleapis.com",
    "meshca.googleapis.com",
    "connectgateway.googleapis.com",
    "trafficdirector.googleapis.com",
    "networkservices.googleapis.com",
    "networksecurity.googleapis.com",
    "monitoring.googleapis.com"
  ])
}

resource "google_project_service" "apis" {
  for_each = local.required_apis

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# ---------------------------------------------------------
# Network
# ---------------------------------------------------------

resource "google_compute_network" "mesh" {
  name                    = var.network_name
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_compute_subnetwork" "mesh" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.mesh.id
  ip_cidr_range = var.subnet_cidr
}

# ---------------------------------------------------------
# GKE
# ---------------------------------------------------------

resource "google_container_cluster" "mesh" {
  name     = var.cluster_name
  location = var.zone

  network    = google_compute_network.mesh.id
  subnetwork = google_compute_subnetwork.mesh.id

  initial_node_count = 1

  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {}

  node_config {
    machine_type = var.machine_type
    disk_type    = "pd-standard"
    disk_size_gb = 30
    image_type   = "COS_CONTAINERD"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "lab"
      exercise    = "service-mesh"
    }
  }

  depends_on = [
    google_project_service.apis
  ]
}

# ---------------------------------------------------------
# Fleet Membership
# ---------------------------------------------------------

resource "google_gke_hub_membership" "mesh" {
  membership_id = var.membership_name
  project       = var.project_id
  location      = var.region

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.mesh.id}"
    }
  }

  labels = {
    environment = "lab"
    purpose     = "service-mesh"
  }

  depends_on = [
    google_container_cluster.mesh
  ]
}

# ---------------------------------------------------------
# Cloud Service Mesh Fleet Feature
# ---------------------------------------------------------

resource "google_gke_hub_feature" "servicemesh" {
  name     = "servicemesh"
  location = "global"
  project  = var.project_id

  depends_on = [
    google_project_service.apis
  ]
}

# ---------------------------------------------------------
# Managed Cloud Service Mesh for this membership
# ---------------------------------------------------------

resource "google_gke_hub_feature_membership" "servicemesh" {
  project             = var.project_id
  location            = "global"
  feature             = google_gke_hub_feature.servicemesh.name
  membership          = google_gke_hub_membership.mesh.membership_id
  membership_location = var.region

  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }

  depends_on = [
    google_gke_hub_membership.mesh,
    google_gke_hub_feature.servicemesh
  ]
}
