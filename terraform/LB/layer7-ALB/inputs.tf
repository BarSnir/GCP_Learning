variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the MIGs"
  type        = string
  default     = "europe-west1"
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "machine_type" {
  description = "Machine type for both instance templates"
  type        = string
  default     = "e2-micro"
}

variable "target_size" {
  description = "Number of instances per MIG"
  type        = number
  default     = 2
}