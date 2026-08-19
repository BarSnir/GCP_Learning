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

resource "google_compute_instance" "payment_vm" {
  name         = "payment-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
  }
}