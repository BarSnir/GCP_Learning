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
  name_prefix  = "ex3-web-tmpl-"
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
      HN=$(hostname)
      cat > /etc/nginx/sites-available/default <<CONF
      server {
          listen 80 default_server;
          location / {
              default_type text/plain;
              return 200 "WEB - $HN\n";
          }
      }
      CONF
      systemctl restart nginx
    EOT
  }
  tags = ["http-server", "ex3-web"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_template" "api_template" {
  name_prefix  = "ex3-api-tmpl-"
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
      HN=$(hostname)
      cat > /etc/nginx/sites-available/default <<CONF
      server {
          listen 80 default_server;
          location / {
              default_type text/plain;
              return 200 "API - $HN\n";
          }
      }
      CONF
      systemctl restart nginx
    EOT
  }
  tags = ["http-server", "ex3-api"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "ex3-web-mig"
  region             = var.region
  base_instance_name = "ex3-web"
  target_size        = var.target_size
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "api_mig" {
  name               = "ex3-api-mig"
  region             = var.region
  base_instance_name = "ex3-api"
  target_size        = var.target_size
  version {
    instance_template = google_compute_instance_template.api_template.id
  }
  named_port {
    name = "http"
    port = 80
  }
}
resource "google_compute_health_check" "http_hc" {
  name = "ex3-http-hc"
  http_health_check {
    port = 80
  }
  check_interval_sec = 5
  timeout_sec         = 5
}

resource "google_compute_backend_service" "web_backend" {
  name                  = "ex3-web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.http_hc.id]
  backend {
    group           = google_compute_region_instance_group_manager.web_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_backend_service" "api_backend" {
  name                  = "ex3-api-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.http_hc.id]
  backend {
    group           = google_compute_region_instance_group_manager.api_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "ex3-web-url-map"
  default_service = google_compute_backend_service.web_backend.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "main-matcher"
  }
  path_matcher {
    name            = "main-matcher"
    default_service = google_compute_backend_service.web_backend.id
    path_rule {
      paths   = ["/api", "/api/*"]
      service = google_compute_backend_service.api_backend.id
    }
  }
}
resource "google_compute_target_http_proxy" "web_http_proxy" {
  name    = "ex3-web-http-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_address" "lb_ip" {
  name = "ex3-web-lb-ip"
}

resource "google_compute_global_forwarding_rule" "web_frontend" {
  name                  = "ex3-web-frontend"
  ip_address            = google_compute_global_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.web_http_proxy.id
}

resource "google_compute_firewall" "allow_lb_and_health_checks" {
  name    = "ex3-allow-lb-hc"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server", "ex3-web", "ex3-api"]
}