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
# --------------------------------------------------------
# custom-machine-type
# --------------------------------------------------------

data "google_compute_image" "debian_12" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_instance" "custom_vm" {
  name         = "custom-vm"
  machine_type = "custom-2-5120"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_12.self_link
      size  = 10
      type  = "pd-balanced"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
}