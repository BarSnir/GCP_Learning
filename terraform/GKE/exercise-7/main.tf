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

locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com"
  ])
}

resource "google_project_service" "required_apis" {
  for_each = local.required_apis

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

#
# Network
#

resource "google_compute_network" "gke_vpc" {
  name                    = "gke-ex7-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-ex7-subnet"
  region        = var.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = "10.100.0.0/24"

  secondary_ip_range {
    range_name    = "gke-ex7-pods"
    ip_cidr_range = "10.101.0.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-ex7-services"
    ip_cidr_range = "10.102.0.0/24"
  }
}

#
# Node Service Account
#

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ex7-node-sa"
  display_name = "GKE Exercise 7 Node Service Account"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_project_iam_member" "gke_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

#
# GKE
#

resource "google_container_cluster" "gke" {
  name     = "gke-ex7"
  location = var.zone

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex7-pods"
    services_secondary_range_name = "gke-ex7-services"
  }

  #
  # Explicitly enable the Compute Engine PD CSI driver.
  #
  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
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

resource "google_container_node_pool" "primary" {
  name     = "gke-ex7-pool"
  location = var.zone
  cluster  = google_container_cluster.gke.name

  node_count = var.node_count

  node_config {
    machine_type = "e2-small"

    disk_type    = "pd-standard"
    disk_size_gb = 20

    image_type = "COS_CONTAINERD"

    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "lab"
      exercise    = "ex7"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_project_iam_member.gke_node_role
  ]
}