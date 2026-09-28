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
  description = "Worker Pool runtime service account"
  type        = string
  default     = "cloud-run-ex6-runtime"
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex6-repo"
}

variable "image_name" {
  description = "Worker container image"
  type        = string
  default     = "background-worker"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v1"
}

variable "worker_pool_name" {
  description = "Cloud Run Worker Pool name"
  type        = string
  default     = "cloud-run-ex6-workers"
}

variable "instance_count" {
  description = "Number of continuously running worker instances"
  type        = number
  default     = 0
}