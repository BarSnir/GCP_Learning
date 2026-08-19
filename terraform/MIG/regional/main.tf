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
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  distribution_policy_zones = [
    "${var.region}-b",
    "${var.region}-c"
  ]
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
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 120
    cpu_utilization {
      target = 0.6
    }
  }
}