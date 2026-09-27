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
  display_name = "Cloud Run Exercise 3 Runtime"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_name
  description   = "Cloud Run Exercise 3 scaling images"
  format        = "DOCKER"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_cloud_run_v2_service" "api" {
  project  = var.project_id
  name     = var.service_name
  location = var.region

  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  # Service-level maximum.
  scaling {
    max_instance_count = var.max_instances
  }

  template {
    service_account = google_service_account.runtime.email

    # Intentionally low for this exercise.
    max_instance_request_concurrency = var.container_concurrency

    # Revision-level minimum.
    scaling {
      min_instance_count = var.min_instances
    }

    containers {
      image = local.image_uri

      ports {
        container_port = 8080
      }

      env {
        name  = "STARTUP_DELAY_SECONDS"
        value = "3"
      }
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.repo
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = google_cloud_run_v2_service.api.location
  name     = google_cloud_run_v2_service.api.name

  role   = "roles/run.invoker"
  member = "allUsers"
}