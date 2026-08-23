terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ---------------------------------------------------------------------------
# Instance Template: e2-micro, nginx installed via startup-script,
# homepage returns the VM's own name.
# ---------------------------------------------------------------------------
resource "google_compute_instance_template" "web_template" {
  name_prefix  = "ex1-web-tmpl-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      echo "$(hostname)" > /var/www/html/index.html
      systemctl restart nginx
    EOT
  }

  tags = ["http-server", "ex1-web"]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Regional Managed Instance Group - 2 instances
# ---------------------------------------------------------------------------
resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "ex1-web-mig"
  region             = var.region
  base_instance_name = "ex1-web"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

# ---------------------------------------------------------------------------
# Health check (regional - required for a regional backend service)
# ---------------------------------------------------------------------------
resource "google_compute_region_health_check" "http_hc" {
  name   = "ex1-http-hc"
  region = var.region
  http_health_check {
    port = 80
  }
  check_interval_sec = 5
  timeout_sec        = 5
}

# ---------------------------------------------------------------------------
# Backend Service for a Regional External Application Load Balancer
# ---------------------------------------------------------------------------
resource "google_compute_region_backend_service" "web_backend" {
  name                  = "ex1-web-backend"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.http_hc.id]
  backend {
    group           = google_compute_region_instance_group_manager.web_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# ---------------------------------------------------------------------------
# URL Map - all paths ("/*") go to the single backend
# ---------------------------------------------------------------------------
resource "google_compute_region_url_map" "web_url_map" {
  name            = "ex1-web-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.web_backend.id
}

# ---------------------------------------------------------------------------
# HTTP Target Proxy
# ---------------------------------------------------------------------------
resource "google_compute_region_target_http_proxy" "web_http_proxy" {
  name    = "ex1-web-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.web_url_map.id
}

# ---------------------------------------------------------------------------
# External Regional IP for the frontend
# ---------------------------------------------------------------------------
resource "google_compute_address" "lb_ip" {
  name         = "ex1-web-lb-ip"
  region       = var.region
  network_tier = "STANDARD" # required for EXTERNAL_MANAGED regional LB
}

# ---------------------------------------------------------------------------
# Frontend: forwarding rule on port 80
# ---------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "web_frontend" {
  name                  = "ex1-web-frontend"
  region                = var.region
  ip_address            = google_compute_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_region_target_http_proxy.web_http_proxy.id
  network_tier          = "STANDARD"
  depends_on = [google_compute_subnetwork.proxy_only]
}

# ---------------------------------------------------------------------------
# Firewall: allow the health check ranges + port 80 from anywhere
# ---------------------------------------------------------------------------
resource "google_compute_firewall" "allow_lb_and_health_checks" {
  name    = "ex1-allow-lb-hc"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # Google health check + external LB source ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "10.0.1.0/24"]
  target_tags   = ["http-server", "ex1-web"]
}

resource "google_compute_subnetwork" "proxy_only" {
  name          = "ex1-proxy-only"
  region        = var.region
  network       = "default"
  ip_cidr_range = "10.0.1.0/24"

  purpose = "REGIONAL_MANAGED_PROXY"
  role    = "ACTIVE"
}

