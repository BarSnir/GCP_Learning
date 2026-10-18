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

variable "workload_namespace" {
  description = "Kubernetes namespace used by the workload"
  type        = string
  default     = "wif-demo"
}

variable "kubernetes_service_account" {
  description = "Kubernetes ServiceAccount that receives GCP IAM permissions"
  type        = string
  default     = "gcs-reader"
}