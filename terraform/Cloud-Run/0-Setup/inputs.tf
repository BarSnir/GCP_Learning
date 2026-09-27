variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "europe-west1"
}

variable "cloud_run_sa_name" {
  description = "Cloud Run runtime service account name"
  type        = string
  default     = "cloud-run-runtime"
}

variable "artifact_repository_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "cloud-run-repo"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "hello-cloud-run"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v2"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "hello-cloud-run"
}