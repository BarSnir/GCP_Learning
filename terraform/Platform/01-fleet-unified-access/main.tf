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
    "gkeconnect.googleapis.com",
    "connectgateway.googleapis.com"
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

resource "google_compute_network" "fleet" {
  name                    = var.network_name
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_compute_subnetwork" "fleet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.fleet.id
  ip_cidr_range = var.subnet_cidr
}

# ---------------------------------------------------------
# GKE
# ---------------------------------------------------------

resource "google_container_cluster" "fleet" {
  name     = var.gke_cluster_name
  location = var.zone

  network    = google_compute_network.fleet.id
  subnetwork = google_compute_subnetwork.fleet.id

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
    machine_type = var.gke_machine_type
    disk_type    = "pd-standard"
    disk_size_gb = 20
    image_type   = "COS_CONTAINERD"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "lab"
      exercise    = "fleet"
    }
  }
}

# ---------------------------------------------------------
# GKE Fleet Membership
# ---------------------------------------------------------

resource "google_gke_hub_membership" "gke" {
  membership_id = var.gke_membership_name
  project       = var.project_id
  location      = var.region

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.fleet.id}"
    }
  }

  labels = {
    environment  = "lab"
    cluster_type = "gke"
  }

  depends_on = [
    google_container_cluster.fleet
  ]
}

# ---------------------------------------------------------
# IAP Firewall
# ---------------------------------------------------------

resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap-external-k8s"
  network = google_compute_network.fleet.name

  direction = "INGRESS"

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = [
    "external-k8s"
  ]

  allow {
    protocol = "tcp"

    ports = [
      "22",
      "6443"
    ]
  }
}

# ---------------------------------------------------------
# External Kubernetes
# ---------------------------------------------------------

resource "google_compute_instance" "external_k8s" {
  name         = var.external_vm_name
  zone         = var.zone
  machine_type = var.external_vm_machine_type

  tags = [
    "external-k8s"
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.fleet.id

    access_config {}
  }

  metadata_startup_script = <<-EOF_SCRIPT
    #!/bin/bash

    set -eux

    apt-get update
    apt-get install -y curl

    curl -sfL https://get.k3s.io | \
      INSTALL_K3S_VERSION="${var.k3s_version}" \
      sh -s - server \
      --disable traefik \
      --write-kubeconfig-mode 644
  EOF_SCRIPT
}

# ---------------------------------------------------------
# External Fleet Registration
# ---------------------------------------------------------

resource "terraform_data" "external_fleet" {
  input = {
    project_id               = var.project_id
    region                   = var.region
    zone                     = var.zone
    vm_name                  = google_compute_instance.external_k8s.name
    external_membership_name = var.external_membership_name
    gke_membership_name      = var.gke_membership_name
    gateway_user             = var.gateway_user
    runtime_dir              = "${path.module}/.runtime"
  }

  depends_on = [
    google_compute_instance.external_k8s,
    google_compute_firewall.allow_iap,
    google_gke_hub_membership.gke,
    google_project_service.apis
  ]

  provisioner "local-exec" {
    command = join(" ", [
      "${path.module}/scripts/register-external.sh",
      self.input.project_id,
      self.input.region,
      self.input.zone,
      self.input.vm_name,
      self.input.external_membership_name,
      self.input.gke_membership_name,
      self.input.gateway_user,
      self.input.runtime_dir
    ])
  }

  provisioner "local-exec" {
    when = destroy

    command = join(" ", [
      "${path.module}/scripts/unregister-external.sh",
      self.input.project_id,
      self.input.region,
      self.input.zone,
      self.input.vm_name,
      self.input.external_membership_name,
      self.input.runtime_dir
    ])
  }
}
