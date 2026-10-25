terraform {
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
    "iam.googleapis.com",
  ])
}

resource "google_project_service" "required_apis" {
  for_each = local.required_apis

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "gke_vpc" {
  name                    = "gke-ex10-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-ex10-subnet"
  region        = var.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = "10.130.0.0/24"

  secondary_ip_range {
    range_name    = "gke-ex10-pods"
    ip_cidr_range = "10.131.0.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-ex10-services"
    ip_cidr_range = "10.132.0.0/24"
  }
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ex10-node-sa"
  display_name = "GKE Exercise 10 Node Service Account"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_project_iam_member" "gke_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "gke" {
  name     = "gke-ex10"
  location = var.zone

  deletion_protection = false

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex10-pods"
    services_secondary_range_name = "gke-ex10-services"
  }

  initial_node_count = 1

  # Cluster-level Shielded GKE Nodes
  enable_shielded_nodes = true

  node_config {
    machine_type = "e2-small"

    disk_type    = "pd-standard"
    disk_size_gb = 20

    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # VM-level Shielded configuration
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      exercise    = "ex10"
      environment = "lab"
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  logging_config {
    enable_components = []
  }

  monitoring_config {
    enable_components = []

    managed_prometheus {
      enabled = false
    }
  }

  depends_on = [
    google_project_iam_member.gke_node_role
  ]
}