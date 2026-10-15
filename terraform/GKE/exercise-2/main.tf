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
    "artifactregistry.googleapis.com",
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
  name                    = "gke-ex2-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-ex2-subnet"
  region        = var.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = "10.50.0.0/24"

  secondary_ip_range {
    range_name    = "gke-ex2-pods"
    ip_cidr_range = "10.51.0.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-ex2-services"
    ip_cidr_range = "10.52.0.0/24"
  }
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ex2-node-sa"
  display_name = "GKE Exercise 2 Node Service Account"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_project_iam_member" "gke_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "gke-ex2"
  description   = "Docker repository for GKE Exercise 2"
  format        = "DOCKER"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_artifact_registry_repository_iam_member" "node_reader" {
  project    = var.project_id
  location   = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "gke" {
  name     = "gke-ex2"
  location = var.zone

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex2-pods"
    services_secondary_range_name = "gke-ex2-services"
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
  name     = "gke-ex2-pool"
  location = var.zone
  cluster  = google_container_cluster.gke.name

  node_count = 1

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
      exercise    = "ex2"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_project_iam_member.gke_node_role
  ]
}

resource "google_compute_firewall" "allow_nodeport" {
  name    = "gke-ex2-allow-nodeport"
  network = google_compute_network.gke_vpc.name

  direction = "INGRESS"

  source_ranges = [
    var.nodeport_source_cidr
  ]

  target_service_accounts = [
    google_service_account.gke_nodes.email
  ]

  allow {
    protocol = "tcp"
    ports    = ["30080"]
  }
}