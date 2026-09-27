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
  default     = "cloud-run-ex4-runtime"
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex4-repo"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "concurrency-api"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "cloud-run-ex4-concurrency"
}

variable "cpu" {
  description = "CPU allocated per instance"
  type        = string
  default     = "2"
}

variable "memory" {
  description = "Memory allocated per instance"
  type        = string
  default     = "1Gi"
}

variable "container_concurrency" {
  description = "Maximum concurrent requests per instance"
  type        = number
  default     = 4
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 2
}