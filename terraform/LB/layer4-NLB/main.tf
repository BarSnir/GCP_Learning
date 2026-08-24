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

resource "google_compute_instance_template" "ex6_tpl" {
  name_prefix  = "ex6-web-"
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

resource "google_compute_region_instance_group_manager" "ex6_mig" {
  name               = "ex6-mig"
  region             = var.region
  base_instance_name = "ex6-web"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.ex6_tpl.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_health_check" "ex6_hc" {
  name   = "ex6-hc"
  region = var.region
  http_health_check {
    port = 80
  }
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

resource "google_compute_region_backend_service" "ex6_backend" {
  name                  = "ex6-backend"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.ex6_hc.id]
  backend {
    group          = google_compute_region_instance_group_manager.ex6_mig.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_address" "ex6_ip" {
  name         = "ex6-lb-ip"
  region       = var.region
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "ex6_fr" {
  name                  = "ex6-fr"
  region                = var.region
  network               = var.network
  subnetwork            = var.subnetwork
  ip_address            = google_compute_address.ex6_ip.address
  ip_protocol           = "TCP"
  ports                 = ["80"]
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ex6_backend.id
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "ex6-allow-health-checks"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["ex6-web"]
}

resource "google_compute_firewall" "allow_internal_clients" {
  name    = "ex6-allow-internal-clients"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.0.0.0/24"]

  target_tags = ["ex6-web"]
}

# Test with client VM

resource "google_compute_instance" "client_vm" {
  name         = "ex6-client-vm"
  zone         = "${var.region}-b"
  machine_type = "e2-micro"

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

output "internal_lb_ip" {
  value = google_compute_address.ex6_ip.address
}