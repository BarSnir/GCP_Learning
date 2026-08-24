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
}

resource "google_compute_instance_template" "ex5_tpl" {
  name_prefix  = "ex5-web-"
  machine_type = "e2-micro"
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {} 
  }
  metadata = {
    startup-script = file("${path.module}/init.sh")
  }
  tags = ["ex5-web"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "ex5_mig" {
  name               = "ex5-mig"
  region             = var.region
  base_instance_name = "ex5-web"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.ex5_tpl.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_health_check" "ex5_hc" {
  name                = "ex5-hc"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    port = 80
  }
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "ex5-allow-health-check"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["ex5-web"]
}

resource "google_compute_firewall" "allow_client_traffic" {
  name    = "ex5-allow-client-traffic"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ex5-web"]
}

resource "google_compute_region_backend_service" "ex5_backend" {
  name                  = "ex5-backend"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.ex5_hc.id]
  timeout_sec           = 30
  backend {
    group          = google_compute_region_instance_group_manager.ex5_mig.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_address" "ex5_ip" {
  name         = "ex5-lb-ip"
  region       = var.region
  network_tier = "PREMIUM"
}

resource "google_compute_forwarding_rule" "ex5_fr" {
  name                  = "ex5-fr"
  region                = var.region
  ip_protocol           = "TCP"
  port_range            = "80"
  ip_address            = google_compute_address.ex5_ip.address
  load_balancing_scheme = "EXTERNAL"
  backend_service       = google_compute_region_backend_service.ex5_backend.id
  network_tier          = "PREMIUM"
}