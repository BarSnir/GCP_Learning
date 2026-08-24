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

variable "target_size" {
  type        = number
  default     = 2
  description = "Number of instances in the managed instance group"
}

variable "region_eu" {
  type        = string
  default     = "europe-west1"
  description = "Region for the European managed instance group"
}

variable "region_us" {
  type        = string
  default     = "us-central1"
  description = "Region for the US managed instance group"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Machine type for the instances"
}

variable "network" {
  type        = string
  default     = "default"
  description = "Network for the instances"
}
