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

resource "google_storage_bucket" "app_source" {
  name                        = "${var.project_id}-appengine-source"
  location                    = "EU"
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "main_py" {
  name   = "python-v1/main.py"
  bucket = google_storage_bucket.app_source.name
  source = "../2-python-hello-world/main.py"
}

resource "google_storage_bucket_object" "requirements" {
  name   = "python-v1/requirements.txt"
  bucket = google_storage_bucket.app_source.name
  source = "../2-python-hello-world/requirements.txt"
}

resource "google_app_engine_standard_app_version" "python_v1" {
  version_id = "v1"
  service    = "default"
  runtime    = "python314"
  entrypoint {
    shell = "gunicorn -k uvicorn.workers.UvicornWorker -b :$PORT main:app"
  }
  deployment {
    files {
      name       = "main.py"
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source.name}/${google_storage_bucket_object.main_py.name}"
    }

    files {
      name       = "requirements.txt"
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source.name}/${google_storage_bucket_object.requirements.name}"
    }
  }
  delete_service_on_destroy = true
  depends_on = [
    google_app_engine_application.app
  ]
}