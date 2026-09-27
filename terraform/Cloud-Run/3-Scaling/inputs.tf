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
  default     = "cloud-run-ex3-runtime"
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex3-repo"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "scaling-api"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v3"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "cloud-run-ex3-scaling"
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 3
}

variable "container_concurrency" {
  description = "Maximum concurrent requests per instance"
  type        = number
  default     = 1
}