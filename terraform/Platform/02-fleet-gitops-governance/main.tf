terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ---------------------------------------------------------
# APIs
# ---------------------------------------------------------

locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "anthospolicycontroller.googleapis.com"
  ])
}

resource "google_project_service" "apis" {
  for_each = local.required_apis

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# ---------------------------------------------------------
# Network
# ---------------------------------------------------------

resource "google_compute_network" "gitops" {
  name                    = var.network_name
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_compute_subnetwork" "gitops" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.gitops.id
  ip_cidr_range = var.subnet_cidr
}

# ---------------------------------------------------------
# GKE
# ---------------------------------------------------------

resource "google_container_cluster" "gitops" {
  name     = var.cluster_name
  location = var.zone

  network    = google_compute_network.gitops.id
  subnetwork = google_compute_subnetwork.gitops.id

  initial_node_count = 1

  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {}

  node_config {
    machine_type = var.machine_type
    disk_type    = "pd-standard"
    disk_size_gb = 20
    image_type   = "COS_CONTAINERD"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "lab"
      exercise    = "fleet-gitops"
    }
  }

  depends_on = [
    google_project_service.apis
  ]
}

# ---------------------------------------------------------
# Config Sync Fleet Default
# ---------------------------------------------------------

resource "google_gke_hub_feature" "configmanagement" {
  name     = "configmanagement"
  location = "global"
  project  = var.project_id

  fleet_default_member_config {
    configmanagement {
      management = "MANAGEMENT_AUTOMATIC"

      config_sync {
        enabled       = true
        source_format = "unstructured"

        git {
          sync_repo   = var.git_repo
          sync_branch = var.git_branch
          policy_dir  = var.policy_dir
          secret_type = "none"
        }
      }
    }
  }

  depends_on = [
    google_project_service.apis
  ]
}

# ---------------------------------------------------------
# Policy Controller Fleet Default
# ---------------------------------------------------------

resource "google_gke_hub_feature" "policycontroller" {
  name     = "policycontroller"
  location = "global"
  project  = var.project_id

  fleet_default_member_config {
    policycontroller {
      policy_controller_hub_config {
        install_spec           = "INSTALL_SPEC_ENABLED"
        audit_interval_seconds = 60
        log_denies_enabled     = true
        mutation_enabled       = false

        policy_content {
          template_library {
            installation = "ALL"
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.apis
  ]
}

# ---------------------------------------------------------
# Fleet Membership
#
# Fleet defaults exist before the cluster joins the Fleet.
# ---------------------------------------------------------

resource "google_gke_hub_membership" "gitops" {
  membership_id = var.membership_name
  project       = var.project_id
  location      = var.region

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.gitops.id}"
    }
  }

  labels = {
    environment = "lab"
    purpose     = "gitops-governance"
  }

  depends_on = [
    google_container_cluster.gitops,
    google_gke_hub_feature.configmanagement,
    google_gke_hub_feature.policycontroller
  ]
}
