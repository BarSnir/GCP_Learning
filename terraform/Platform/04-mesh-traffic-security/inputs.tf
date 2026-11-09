variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west1-b"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "mesh-traffic-network"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "mesh-traffic-subnet"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.40.0.0/20"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "mesh-traffic-gke"
}

variable "membership_name" {
  description = "Fleet membership name"
  type        = string
  default     = "mesh-traffic-membership"
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-2"
}
