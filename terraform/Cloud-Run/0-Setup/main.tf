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
  image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repository_name}/${var.image_name}:${var.image_tag}"
}


resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)
  project = var.project_id
  service = each.value
  disable_on_destroy = false
}


resource "google_service_account" "cloud_run_runtime" {
  project      = var.project_id
  account_id   = var.cloud_run_sa_name
  display_name = "Cloud Run Runtime Service Account"

  depends_on = [
    google_project_service.required_apis
  ]
}


resource "google_artifact_registry_repository" "cloud_run_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_repository_name
  description   = "Docker repository for Cloud Run exercises"
  format        = "DOCKER"

  depends_on = [
    google_project_service.required_apis
  ]
}


resource "google_cloud_run_v2_service" "app" {
  project  = var.project_id
  name     = var.cloud_run_service_name
  location = var.region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"
  template {
    service_account = google_service_account.cloud_run_runtime.email
    containers {
      image = local.image_uri
      ports {
        container_port = 8080
      }
    }
  }
  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.cloud_run_repo
  ]
}


resource "google_cloud_run_service_iam_binding" "public" {
  project  = var.project_id
  location = google_cloud_run_v2_service.app.location
  service  = google_cloud_run_v2_service.app.name
  role = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}