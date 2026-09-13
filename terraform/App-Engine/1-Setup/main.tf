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
}

resource "google_service_account" "app_engine_deployer" {
  account_id   = "app-engine-deployer"
  display_name = "App Engine Deployer"
}

resource "google_project_iam_member" "app_engine_deployer" {
  project = var.project_id
  role    = "roles/appengine.deployer"
  member  = "serviceAccount:${google_service_account.app_engine_deployer.email}"
}

locals {
  app_engine_deployer_roles = [
    "roles/appengine.deployer",
    "roles/cloudbuild.builds.editor",
    "roles/storage.objectAdmin"
  ]
}

resource "google_project_iam_member" "app_engine_deployer_roles" {
  for_each = toset(local.app_engine_deployer_roles)
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.app_engine_deployer.email}"
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.app_engine_location
}