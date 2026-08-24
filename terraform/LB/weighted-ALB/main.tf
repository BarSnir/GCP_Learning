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

locals {
  apps = {
    web_v1 = {
      name = "web-v1"
      role = "WEB-V1"
    }

    web_v2 = {
      name = "web-v2"
      role = "WEB-V2"
    }

    api = {
      name = "api"
      role = "API"
    }
  }
}

# ---------------------------------------------------------------------------
# Instance Templates
# ---------------------------------------------------------------------------

resource "google_compute_instance_template" "app_template" {
  for_each = local.apps

  name_prefix  = "${each.value.name}-tmpl-"
  machine_type = var.machine_type

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = var.network

    access_config {}
  }

  metadata = {
    startup-script = file("${path.module}/init.sh")
    app_role       = each.value.role
  }

  tags = ["http-server"]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Regional MIGs
# ---------------------------------------------------------------------------

resource "google_compute_region_instance_group_manager" "web_v1_mig" {
  name               = "web-v1-mig"
  region             = var.region_eu
  base_instance_name = "web-v1"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.app_template["web_v1"].id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "web_v2_mig" {
  name               = "web-v2-mig"
  region             = var.region_eu
  base_instance_name = "web-v2"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.app_template["web_v2"].id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_instance_group_manager" "api_mig" {
  name               = "api-mig"
  region             = var.region_eu
  base_instance_name = "api"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.app_template["api"].id
  }

  named_port {
    name = "http"
    port = 80
  }
}

# ---------------------------------------------------------------------------
# Health Check
# ---------------------------------------------------------------------------

resource "google_compute_health_check" "http_hc" {
  name = "weighted-http-hc"

  http_health_check {
    port = 80
  }

  check_interval_sec = 5
  timeout_sec        = 5
}

# ---------------------------------------------------------------------------
# Backend Services
# ---------------------------------------------------------------------------

resource "google_compute_backend_service" "web_v1_backend" {
  name                  = "web-v1-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_checks = [
    google_compute_health_check.http_hc.id
  ]

  backend {
    group           = google_compute_region_instance_group_manager.web_v1_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_backend_service" "web_v2_backend" {
  name                  = "web-v2-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_checks = [
    google_compute_health_check.http_hc.id
  ]

  backend {
    group           = google_compute_region_instance_group_manager.web_v2_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_backend_service" "api_backend" {
  name                  = "api-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_checks = [
    google_compute_health_check.http_hc.id
  ]

  backend {
    group           = google_compute_region_instance_group_manager.api_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# ---------------------------------------------------------------------------
# URL Map
# /api/* -> API backend
# everything else -> 80% V1 / 20% V2
# ---------------------------------------------------------------------------

resource "google_compute_url_map" "weighted_url_map" {
  name            = "weighted-url-map"
  default_service = google_compute_backend_service.web_v1_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "main"
  }

  path_matcher {
    name            = "main"
    default_service = google_compute_backend_service.web_v1_backend.id

    route_rules {
      priority = 1

      match_rules {
        prefix_match = "/api/"
      }

      service = google_compute_backend_service.api_backend.id
    }

    route_rules {
      priority = 10

      match_rules {
        prefix_match = "/"
      }

      route_action {
        weighted_backend_services {
          backend_service = google_compute_backend_service.web_v1_backend.id
          weight          = 80
        }

        weighted_backend_services {
          backend_service = google_compute_backend_service.web_v2_backend.id
          weight          = 20
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Frontend
# ---------------------------------------------------------------------------

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "weighted-http-proxy"
  url_map = google_compute_url_map.weighted_url_map.id
}

resource "google_compute_global_address" "lb_ip" {
  name = "weighted-lb-ip"
}

resource "google_compute_global_forwarding_rule" "frontend" {
  name                  = "weighted-frontend"
  ip_address            = google_compute_global_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.http_proxy.id
}

# ---------------------------------------------------------------------------
# Firewall
# ---------------------------------------------------------------------------

resource "google_compute_firewall" "allow_lb_and_health_checks" {
  name    = "weighted-allow-lb-hc"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["http-server"]
}

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

output "lb_ip" {
  value = google_compute_global_address.lb_ip.address
}