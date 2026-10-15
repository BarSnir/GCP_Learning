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
  description = "GKE zone"
  type        = string
  default     = "europe-west1-b"
}

variable "nodeport_source_cidr" {
  description = "Public CIDR allowed to access the NodePort"
  type        = string
}