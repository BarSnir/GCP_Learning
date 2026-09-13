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

locals {
  deployments = {
    frontend_v1 = {
      service = "frontend"
      version = "v1"
      path    = "frontend-v1"
    }

    frontend_v2 = {
      service = "frontend"
      version = "v2"
      path    = "frontend-v2"
    }

    api_v1 = {
      service = "api"
      version = "v1"
      path    = "api"
    }

    worker_v1 = {
      service = "worker"
      version = "v1"
      path    = "worker"
    }
  }
}

data "archive_file" "apps" {
  for_each = local.deployments

  type        = "zip"
  output_path = "${path.module}/${each.key}.zip"

  source {
    content  = file("${path.module}/${each.value.path}/main.py")
    filename = "main.py"
  }

  source {
    content  = file("${path.module}/${each.value.path}/requirements.txt")
    filename = "requirements.txt"
  }
}

resource "google_storage_bucket" "app_source" {
  name                        = "${var.project_id}-final-python-source"
  location                    = "EU"
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "apps" {
  for_each = local.deployments

  name   = "${each.value.service}-${each.value.version}.zip"
  bucket = google_storage_bucket.app_source.name
  source = data.archive_file.apps[each.key].output_path
}

resource "google_app_engine_standard_app_version" "apps" {
  for_each = local.deployments

  project    = var.project_id
  service    = each.value.service
  version_id = each.value.version
  runtime    = "python314"

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source.name}/${google_storage_bucket_object.apps[each.key].name}"
    }
  }

  entrypoint {
    shell = "gunicorn -k uvicorn.workers.UvicornWorker -b :$PORT main:app"
  }

  instance_class = "F1"

  inbound_services = [
    "INBOUND_SERVICE_WARMUP"
  ]

  automatic_scaling {
    standard_scheduler_settings {
      min_instances = each.value.service == "worker" ? 0 : 1
      max_instances = each.value.service == "frontend" ? 5 : 3
      target_cpu_utilization = each.value.service == "frontend" ? 0.60 : 0.75
    }
  }

  delete_service_on_destroy = true
}