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

data "google_compute_image" "debian_12" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_instance_template" "web_template" {
  name         = "web-template"
  machine_type = "e2-micro"
  disk {
    source_image = data.google_compute_image.debian_12.self_link
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
  }
  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_instance_group_manager" "web_mig" {
  name               = "web-mig"
  zone               = var.zone
  base_instance_name = "web-vm"
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
}
