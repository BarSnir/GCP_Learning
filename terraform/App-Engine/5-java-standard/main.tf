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
  versions = {
    v1 = {
      message = "Hello from Java App Engine Standard - V1"
    }
    v2 = {
      message = "Hello from Java App Engine Standard - V2"
    }
  }
}

data "archive_file" "java_app" {
  for_each = local.versions

  type        = "zip"
  output_path = "${path.module}/java-${each.key}.zip"

  source {
    content  = file("${path.module}/pom.xml")
    filename = "pom.xml"
  }

  source {
    content  = file("${path.module}/src-${each.key}/Main.java")
    filename = "src/main/java/Main.java"
  }
}

resource "google_storage_bucket" "app_source" {
  name                        = "${var.project_id}-java-api-source"
  location                    = "EU"
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "java_app" {
  for_each = local.versions

  name   = "java-api-${each.key}.zip"
  bucket = google_storage_bucket.app_source.name
  source = data.archive_file.java_app[each.key].output_path
}

resource "google_app_engine_standard_app_version" "java_versions" {
  for_each = local.versions

  project    = var.project_id
  service    = "java-api"
  version_id = each.key
  runtime    = "java21"

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source.name}/${google_storage_bucket_object.java_app[each.key].name}"
    }
  }

  inbound_services = [
    "INBOUND_SERVICE_WARMUP"
  ]
  entrypoint {
    shell = "java -jar target/java-app-engine-1.0.0.jar"
  }

  instance_class = "F1"

  automatic_scaling {
    standard_scheduler_settings {
      min_instances = 1
      max_instances = 3
    }
  }

  delete_service_on_destroy = true
}