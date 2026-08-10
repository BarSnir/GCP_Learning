variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Google Cloud zone"
  type        = string
  default     = "europe-west1-b"
}

variable "instance_name" {
  description = "Name of the GCE instance"
  type        = string
  default     = "terraform-vm-custom-image"
}

variable "machine_type" {
  description = "Machine type for the GCE instance"
  type        = string
  default     = "e2-micro"
}