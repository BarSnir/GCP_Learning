variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "service_account_name" {
  description = "Cloud Run runtime service account"
  type        = string
  default     = "cloud-run-ex2-runtime"
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex2-repo"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "revision-api"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v2"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "cloud-run-ex2-api"
}

variable "revision_name" {
  description = "Explicit Cloud Run revision name"
  type        = string
  default     = "cloud-run-ex2-api-v2"
}