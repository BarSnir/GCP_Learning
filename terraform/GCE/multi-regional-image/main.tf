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
# Custome image
# --------------------------------------------------------
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_disk" "web-image-v1-disk" {
  name  = "web-image-v1-disk"
  image = data.google_compute_image.debian.self_link
  size  = 10
  type  = "pd-balanced"
  zone  = var.zone
}

resource "google_compute_image" "web-image-v1" {
  name = "web-image-v1"
  source_disk = google_compute_disk.web-image-v1-disk.id
  storage_locations = ["eu"]
}
# --------------------------------------------------------
# VM using custom image
# --------------------------------------------------------
resource "google_compute_instance" "web-from-image" {
  name         = "web-from-image"
  machine_type = "e2-micro"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = google_compute_image.web-image-v1.self_link
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
}