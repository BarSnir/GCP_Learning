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
  default     = "cloud-run-ex7-runtime"
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex7-repo"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "deploy-demo"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "cloud-run-ex7-image"
}