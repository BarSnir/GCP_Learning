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
  name         = "web-template-v1"
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

resource "google_compute_health_check" "http_health_check" {
  name               = "web-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  http_health_check {
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "web_mig_regional" {
  name               = "web-mig-regional"
  region             = var.region
  base_instance_name = "web-vm"
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 3
    max_unavailable_fixed = 0
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.id
    initial_delay_sec = 120
  }
}
resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web_mig_regional.id
  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 2
    cooldown_period = 120
    cpu_utilization {
      target = 0.6
    }
    scale_in_control {
      max_scaled_in_replicas {
        percent = 10
      }
      time_window_sec = 300
    }
  }
}
