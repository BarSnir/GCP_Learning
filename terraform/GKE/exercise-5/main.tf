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

data "google_project" "current" {
  project_id = var.project_id
}

locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com"
  ])

  workload_identity_principal = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.workload_namespace}/sa/${var.kubernetes_service_account}"
}

resource "google_project_service" "required_apis" {
  for_each = local.required_apis

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

#
# Networking
#

resource "google_compute_network" "gke_vpc" {
  name                    = "gke-ex5-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-ex5-subnet"
  region        = var.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = "10.80.0.0/24"

  secondary_ip_range {
    range_name    = "gke-ex5-pods"
    ip_cidr_range = "10.81.0.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-ex5-services"
    ip_cidr_range = "10.82.0.0/24"
  }
}

#
# Node Service Account
#

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ex5-node-sa"
  display_name = "GKE Exercise 5 Node Service Account"

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
  name     = "gke-ex5"
  location = var.zone

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex5-pods"
    services_secondary_range_name = "gke-ex5-services"
  }

  #
  # Enable Workload Identity Federation for GKE
  #
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

resource "google_container_node_pool" "primary" {
  name     = "gke-ex5-pool"
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

    #
    # Pods use the GKE metadata server / Workload Identity,
    # not the node's IAM identity.
    #
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      environment = "lab"
      exercise    = "ex5"
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
# Cloud Storage resource that the workload will access
#

resource "google_storage_bucket" "demo" {
  name     = "gke-ex5-wif-${var.project_id}"
  location = var.region

  uniform_bucket_level_access = true

  force_destroy = true

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_storage_bucket_object" "demo_file" {
  name   = "hello.txt"
  bucket = google_storage_bucket.demo.name

  content = <<-EOT
    Hello from Cloud Storage.
    This object was read by a GKE workload using Workload Identity Federation.
  EOT
}

#
# IAM is granted directly to the Kubernetes ServiceAccount identity.
#

resource "google_storage_bucket_iam_member" "workload_reader" {
  bucket = google_storage_bucket.demo.name
  role   = "roles/storage.objectViewer"

  member = local.workload_identity_principal
}