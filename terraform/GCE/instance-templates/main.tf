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

data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_disk" "persistent" {
  name  = "example-disk"
  image = data.google_compute_image.debian.self_link
  size  = 10
  type  = "pd-ssd"
  zone  = var.zone
}

resource "google_compute_image" "my-custom-image" {
  name = "my-custom-image"
  source_disk = google_compute_disk.persistent.id
}

resource "google_compute_firewall" "rules" {
  project     = var.project_id
  name        = "my-firewall-rule"
  network     = var.network
  description = "Creates firewall rule targeting tagged instances"
  allow {
    protocol  = "tcp"
    ports     = ["80", "8080", "1000-2000"]
  }
  source_tags = ["foo"]
  target_tags = ["web"]
}

resource "google_compute_address" "static_ip" {
  name   = "my-static-ip"
  region = var.region
}

resource "google_compute_instance_template" "web_template" {
  name        = "nginx-startup-template"
  description = "Template containing startup script for future VMs"
  machine_type = "e2-micro"
  disk {
    source_image = google_compute_image.my-custom-image.self_link
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network = var.network
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update && apt-get install -y nginx
    systemctl enable nginx
    echo "<h1>Hello from Terraform Template</h1>" > /var/www/html/index.html
  EOF
  tags = ["http-server"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-rule"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}