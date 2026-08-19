terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ------------------------------------------------------------------------------
# 1. Sole-Tenant Node Template (ה-Host הפיזי הזול ביותר בנמצא)
# ------------------------------------------------------------------------------
resource "google_compute_node_template" "payment_node_template" {
  name      = "payment-node-template"
  region    = var.region
  node_type = "n1-node-96-624" # ה-Node הפיזי עם העלות השעתית הנמוכה ביותר

  server_binding {
    type = "RESTART_NODE_ON_ANY_SERVER"
  }
}

# ------------------------------------------------------------------------------
# 2. Sole-Tenant Node Group (הקצאת השרת הפיזי)
# ------------------------------------------------------------------------------
resource "google_compute_node_group" "payment_node_group" {
  name          = "payment-node-group"
  zone          = var.zone
  node_template = google_compute_node_template.payment_node_template.id
  initial_size  = 1
}
data "google_compute_image" "debian_12" {
  family  = "debian-12"
  project = "debian-cloud"
}
resource "google_compute_instance" "payment_vm" {
  name         = "payment-vm"
  machine_type = "n1-standard-1"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_12.self_link
      size  = 10
      type  = "pd-standard"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
    node_affinities {
      key      = "node_group"
      operator = "IN"
      values   = [google_compute_node_group.payment_node_group.name]
    }
  }
}