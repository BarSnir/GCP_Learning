terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "archive_file" "node_app" {
  type        = "zip"
  output_path = "${path.module}/node-app.zip"

  source {
    content  = file("${path.module}/server.js")
    filename = "server.js"
  }

  source {
    content  = file("${path.module}/package.json")
    filename = "package.json"
  }

  source {
    content  = file("${path.module}/package-lock.json")
    filename = "package-lock.json"
  }
}

resource "google_storage_bucket" "app_source" {
  name                        = "${var.project_id}-node-flex-source"
  location                    = "EU"
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "node_app" {
  name   = "node-flex-v1.zip"
  bucket = google_storage_bucket.app_source.name
  source = data.archive_file.node_app.output_path
}

resource "google_app_engine_flexible_app_version" "node_v1" {
  version_id = "v1"
  service    = "node-flex"
  runtime    = "nodejs"

  flexible_runtime_settings {
    operating_system = "ubuntu24"
    runtime_version  = "24"
  }

  delete_service_on_destroy = true

  entrypoint {
    shell = "npm start"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source.name}/${google_storage_bucket_object.node_app.name}"
    }
  }

  manual_scaling {
    instances = 1
  }

  resources {
    cpu       = 1
    memory_gb = 0.5
    disk_gb   = 10
  }

  liveness_check {
    path = "/"
  }

  readiness_check {
    path              = "/"
    app_start_timeout = "600s"
  }
}
