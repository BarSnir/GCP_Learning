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

resource "google_compute_network" "gke_vpc" {
  name                    = "gke-ex1-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-ex1-subnet"
  region        = var.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = "10.40.0.0/24"

  secondary_ip_range {
    range_name    = "gke-ex1-pods"
    ip_cidr_range = "10.41.0.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-ex1-services"
    ip_cidr_range = "10.42.0.0/24"
  }
}

resource "google_service_account" "standard_nodes" {
  account_id   = "gke-ex1-node-sa"
  display_name = "GKE Exercise 1 Standard Node SA"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_project_iam_member" "standard_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.standard_nodes.email}"
}

#
# STANDARD CLUSTER
#

resource "google_container_cluster" "standard" {
  name     = "gke-ex1-standard"
  location = var.zone

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex1-pods"
    services_secondary_range_name = "gke-ex1-services"
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

resource "google_container_node_pool" "standard_pool" {
  name     = "gke-ex1-standard-pool"
  location = var.zone
  cluster  = google_container_cluster.standard.name

  node_count = 1

  node_config {
    machine_type = "e2-small"

    disk_type    = "pd-standard"
    disk_size_gb = 20

    image_type = "COS_CONTAINERD"

    service_account = google_service_account.standard_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      mode     = "standard"
      exercise = "ex1"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_project_iam_member.standard_node_role
  ]
}

#
# AUTOPILOT CLUSTER
#

resource "google_container_cluster" "autopilot" {
  name     = "gke-ex1-autopilot"
  location = var.region

  enable_autopilot = true

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex1-pods"
    services_secondary_range_name = "gke-ex1-services"
  }

  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_service.required_apis
  ]
}