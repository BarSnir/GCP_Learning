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
}

resource "google_compute_instance_template" "web_template" {
  name_prefix  = "ex2-web-tmpl-"
  machine_type = var.machine_type
  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network       = var.network
    access_config {}
  }
  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      echo "vm: $(hostname)" > /var/www/html/index.html
      systemctl restart nginx
    EOT
  }

  tags = ["http-server", "ex2-web"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "web_mig_eu" {
  name               = "ex2-web-mig-eu"
  region             = var.region_eu
  base_instance_name = "ex2-web-eu"
  target_size        = var.target_size
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "web_mig_us" {
  name               = "ex2-web-mig-us"
  region             = var.region_us
  base_instance_name = "ex2-web-us"
  target_size        = var.target_size
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http_hc" {
  name = "ex2-http-hc"
  http_health_check {
    port = 80
  }
  check_interval_sec = 5
  timeout_sec         = 5
}

resource "google_compute_backend_service" "web_backend" {
  name                  = "ex2-web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.http_hc.id]
  backend {
    group           = google_compute_region_instance_group_manager.web_mig_eu.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  backend {
    group           = google_compute_region_instance_group_manager.web_mig_us.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "ex2-web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_http_proxy" {
  name    = "ex2-web-http-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_address" "lb_ip" {
  name = "ex2-web-lb-ip"
}

resource "google_compute_global_forwarding_rule" "web_frontend" {
  name                  = "ex2-web-frontend"
  ip_address            = google_compute_global_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.web_http_proxy.id
}

resource "google_compute_firewall" "allow_lb_and_health_checks" {
  name    = "ex2-allow-lb-hc"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server", "ex2-web"]
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}
