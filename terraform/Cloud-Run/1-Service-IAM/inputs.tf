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
  default     = "cloud-run-ex1-runtime"
}

variable "caller_service_account_name" {
  description = "Service Account used to invoke Cloud Run"
  type        = string
  default     = "cloud-run-ex1-caller"
}

variable "invoker_user" {
  description = "User allowed to impersonate caller SA"
  type        = string
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex1-repo"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "api-service"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "cloud-run-ex1-api"
}