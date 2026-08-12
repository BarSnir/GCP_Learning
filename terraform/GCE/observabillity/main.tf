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

# 1. יצירת Service Account למכונה עם הרשאות לכתיבת לוגים ומטריקות
resource "google_service_account" "monitoring_sa" {
  account_id   = "gce-monitoring-sa"
  display_name = "Service Account for GCE Ops Agent"
}

# הענקת הרשאות כתיבה ל-Cloud Logging ו-Cloud Monitoring
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.monitoring_sa.email}"
}

resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.monitoring_sa.email}"
}

resource "google_compute_instance" "monitoring_vm" {
  name         = "gce-metrics-logging-demo"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.monitoring_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    bash add-google-cloud-ops-agent-repo.sh --also-install
    apt-get update
    apt-get install -y stress
    logger -t MY_APP_LOG "Custom application booted and Ops Agent installed successfully"
  EOF

  tags = ["monitoring-demo"]
}

resource "google_monitoring_alert_policy" "cpu_high_alert" {
  display_name = "High CPU Utilization Alert (>70%)"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization is above 70%"

    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\" AND resource.label.instance_id=\"${google_compute_instance.monitoring_vm.instance_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.7
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}