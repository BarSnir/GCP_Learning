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
    "iam.googleapis.com",
    "iamcredentials.googleapis.com"
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
  display_name = "Cloud Run Exercise 1 Runtime"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_service_account" "caller" {
  project      = var.project_id
  account_id   = var.caller_service_account_name
  display_name = "Cloud Run Exercise 1 Caller"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_name
  format        = "DOCKER"

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_cloud_run_v2_service" "api" {
  project  = var.project_id
  name     = var.service_name
  location = var.region

  deletion_protection  = false
  ingress              = "INGRESS_TRAFFIC_ALL"
  invoker_iam_disabled = false

  template {
    service_account = google_service_account.runtime.email

    containers {
      image = local.image_uri

      ports {
        container_port = 8080
      }
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.repo
  ]
}

resource "google_cloud_run_v2_service_iam_member" "caller_invoker" {
  project  = var.project_id
  location = google_cloud_run_v2_service.api.location
  name     = google_cloud_run_v2_service.api.name

  role   = "roles/run.invoker"
  member = "serviceAccount:${google_service_account.caller.email}"
}

resource "google_service_account_iam_member" "user_can_impersonate_caller" {
  service_account_id = google_service_account.caller.name

  role   = "roles/iam.serviceAccountTokenCreator"
  member = "user:${var.invoker_user}"
}