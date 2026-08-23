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

variable "region_eu" {
  description = "First region"
  type        = string
  default     = "europe-west1"
}

variable "region_us" {
  description = "Second region"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "VPC network name (auto-mode 'default' has subnets in every region already)"
  type        = string
  default     = "default"
}

variable "machine_type" {
  description = "Machine type for the instance templates"
  type        = string
  default     = "e2-micro"
}

variable "target_size" {
  description = "Number of instances per regional MIG"
  type        = number
  default     = 2
}