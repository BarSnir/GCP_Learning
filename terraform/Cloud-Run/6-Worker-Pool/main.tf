terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.2"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  required_apis = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com"
  ]

  image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.image_name}:${var.image_tag}"
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Cloud Run Exercise 6 Worker Runtime"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_name
  description   = "Cloud Run Exercise 6 worker images"
  format        = "DOCKER"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_cloud_run_v2_worker_pool" "workers" {
  project  = var.project_id
  name     = var.worker_pool_name
  location = var.region

  deletion_protection = false

  template {
    service_account = google_service_account.runtime.email

    containers {
      image = local.image_uri

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "WORKER_VERSION"
        value = var.image_tag
      }
    }
  }

  scaling {
    scaling_mode          = "MANUAL"
    manual_instance_count = var.instance_count
  }

  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.repo
  ]
}