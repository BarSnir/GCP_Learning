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

resource "google_compute_subnetwork" "proxy_only" {
  name          = "ex4-proxy-only-subnet"
  region        = var.region
  network       = var.network
  ip_cidr_range = var.proxy_subnet_cidr
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# ---------------------------------------------------------------------------
resource "google_compute_instance_template" "web_template" {
  name_prefix  = "ex4-web-tmpl-"
  machine_type = var.machine_type
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
              return 200 "INTERNAL APP - $HN\n";
          }
      }
      CONF
      systemctl restart nginx
    EOT
  }

  tags = ["ex4-web"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "ex4-web-mig"
  region             = var.region
  base_instance_name = "ex4-web"
  target_size        = var.target_size
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_health_check" "http_hc" {
  name   = "ex4-http-hc"
  region = var.region

  http_health_check {
    port = 80
  }

  check_interval_sec = 5
  timeout_sec         = 5
}

resource "google_compute_region_backend_service" "web_backend" {
  name                  = "ex4-web-backend"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.http_hc.id]

  backend {
    group           = google_compute_region_instance_group_manager.web_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_url_map" "web_url_map" {
  name            = "ex4-web-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.web_backend.id
}

resource "google_compute_region_target_http_proxy" "web_http_proxy" {
  name    = "ex4-web-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.web_url_map.id
}

resource "google_compute_address" "lb_ip" {
  name         = "ex4-web-lb-ip"
  region       = var.region
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "web_frontend" {
  name                  = "ex4-web-frontend"
  region                = var.region
  network               = var.network
  subnetwork            = var.subnetwork
  ip_address             = google_compute_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target                = google_compute_region_target_http_proxy.web_http_proxy.id
}

resource "google_compute_firewall" "allow_proxy_only_subnet" {
  name    = "ex4-allow-proxy-only"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [google_compute_subnetwork.proxy_only.ip_cidr_range]
  target_tags   = ["ex4-web"]
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "ex4-allow-iap-ssh"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_instance" "client_vm" {
  name         = "ex4-client-vm"
  zone         = "${var.region}-b"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {}
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "ex4-allow-health-checks"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "35.191.0.0/16"
  ]

  target_tags = ["ex4-web"]
}