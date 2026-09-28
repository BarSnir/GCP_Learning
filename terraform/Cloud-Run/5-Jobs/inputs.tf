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
  description = "Cloud Run Job runtime service account"
  type        = string
  default     = "cloud-run-ex5-runtime"
}

variable "repository_name" {
  description = "Artifact Registry repository"
  type        = string
  default     = "cloud-run-ex5-repo"
}

variable "image_name" {
  description = "Job container image"
  type        = string
  default     = "batch-job"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v2"
}

variable "job_name" {
  description = "Cloud Run Job name"
  type        = string
  default     = "cloud-run-ex5-batch"
}

variable "task_count" {
  description = "Number of tasks in each execution"
  type        = number
  default     = 6
}

variable "parallelism" {
  description = "Maximum number of tasks running concurrently"
  type        = number
  default     = 6
}