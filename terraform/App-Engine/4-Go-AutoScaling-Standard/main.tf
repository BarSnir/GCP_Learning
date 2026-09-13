terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
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


# -----------------------------
# Package the COMPILED Go app
# -----------------------------

data "archive_file" "go_app" {
  type        = "zip"
  output_path = "${path.module}/go-app.zip"

  source {
    content  = file("${path.module}/main.go")
    filename = "main.go"
  }

  source {
    content  = file("${path.module}/go.mod")
    filename = "go.mod"
  }
}


# -----------------------------
# Storage for deployment artifact
# -----------------------------

resource "google_storage_bucket" "app_source" {
  name                        = "${var.project_id}-go-standard-source"
  location                    = "EU"
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "go_app" {
  name   = "${var.service_name}-${var.version_id}.zip"
  bucket = google_storage_bucket.app_source.name
  source = data.archive_file.go_app.output_path
}

# -----------------------------
# App Engine Standard Version
# -----------------------------

resource "google_app_engine_standard_app_version" "go_app" {
  project    = var.project_id
  service    = var.service_name
  version_id = var.version_id
  runtime    = "go127"

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source.name}/${google_storage_bucket_object.go_app.name}"
    }
  }

  entrypoint {
    shell = "main"
  }

  instance_class = "F1"

  automatic_scaling {
    max_concurrent_requests = 20

    standard_scheduler_settings {
      target_cpu_utilization = 0.60
      min_instances          = 1
      max_instances          = 5
    }
  }

  delete_service_on_destroy = true
}