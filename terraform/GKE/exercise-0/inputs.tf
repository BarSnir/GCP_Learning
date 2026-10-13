variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Default GCP zone"
  type        = string
  default     = "europe-west1-b"
}

variable "node_count" {
  description = "Number of worker nodes in the lab node pool"
  type        = number
  default     = 0
}