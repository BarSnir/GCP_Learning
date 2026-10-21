terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "telemetry.googleapis.com",
    "cloudtrace.googleapis.com",
    "pubsub.googleapis.com"
  ])
}

resource "google_project_service" "required_apis" {
  for_each = local.required_apis

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

#
# Networking
#

resource "google_compute_network" "gke_vpc" {
  name                    = "gke-ex6-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-ex6-subnet"
  region        = var.region
  network       = google_compute_network.gke_vpc.id
  ip_cidr_range = "10.90.0.0/24"

  secondary_ip_range {
    range_name    = "gke-ex6-pods"
    ip_cidr_range = "10.91.0.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-ex6-services"
    ip_cidr_range = "10.92.0.0/24"
  }
}

#
# GKE Node Service Account
#

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ex6-node-sa"
  display_name = "GKE Exercise 6 Node Service Account"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_project_iam_member" "gke_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

#
# GKE
#

resource "google_container_cluster" "gke" {
  provider = google-beta

  name     = "gke-ex6"
  location = var.zone

  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-ex6-pods"
    services_secondary_range_name = "gke-ex6-services"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS"
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS"
    ]

    managed_prometheus {
      enabled = true
    }
  }

  managed_opentelemetry_config {
    scope = "COLLECTION_AND_INSTRUMENTATION_COMPONENTS"
  }

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_container_node_pool" "primary" {
  provider = google-beta

  name     = "gke-ex6-pool"
  location = var.zone
  cluster  = google_container_cluster.gke.name

  node_count = var.node_count

  node_config {
    machine_type = "e2-small"

    disk_type    = "pd-standard"
    disk_size_gb = 20

    image_type = "COS_CONTAINERD"

    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "lab"
      exercise    = "ex6"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_project_iam_member.gke_node_role
  ]
}

#
# Pub/Sub destination for GKE logs
#

resource "google_pubsub_topic" "gke_logs" {
  name = "gke-ex6-logs"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_pubsub_subscription" "gke_logs" {
  name  = "gke-ex6-logs-sub"
  topic = google_pubsub_topic.gke_logs.name

  message_retention_duration = "600s"
}

#
# Cloud Logging Sink
#

resource "google_logging_project_sink" "gke_logs" {
  name = "gke-ex6-pubsub-sink"

  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.gke_logs.name}"

  filter = <<-EOT
resource.type="k8s_container"
resource.labels.cluster_name="gke-ex6"
jsonPayload.service="gke-observability-demo"
EOT

  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "logging_sink_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.gke_logs.name

  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.gke_logs.writer_identity
}

#
# Log-based Alert
#

resource "google_monitoring_alert_policy" "gke_error_log" {
  display_name = "GKE Exercise 6 - Application ERROR Log"
  combiner     = "OR"

  conditions {
    display_name = "ERROR from gke-observability-demo"

    condition_matched_log {
      filter = <<-EOT
resource.type="k8s_container"
resource.labels.cluster_name="gke-ex6"
jsonPayload.service="gke-observability-demo"
severity>=ERROR
EOT
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }

    auto_close = "1800s"
  }

  documentation {
    content = "An ERROR structured log was emitted by the GKE Exercise 6 observability demo."
  }

  enabled = true

  depends_on = [
    google_project_service.required_apis
  ]
}