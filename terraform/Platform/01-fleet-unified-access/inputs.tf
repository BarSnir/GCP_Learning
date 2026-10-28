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
  default     = "fleet-network"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "fleet-subnet"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.10.0.0/20"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "fleet-gke"
}

variable "gke_membership_name" {
  description = "GKE Fleet membership name"
  type        = string
  default     = "fleet-gke-membership"
}

variable "gke_machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-small"
}

variable "external_vm_name" {
  description = "External Kubernetes VM name"
  type        = string
  default     = "external-k8s"
}

variable "external_vm_machine_type" {
  description = "External Kubernetes VM machine type"
  type        = string
  default     = "e2-small"
}

variable "external_membership_name" {
  description = "External Kubernetes Fleet membership name"
  type        = string
  default     = "external-k8s-membership"
}

variable "k3s_version" {
  description = "K3s version"
  type        = string
  default     = "v1.35.9+k3s1"
}

variable "gateway_user" {
  description = "Google user allowed to access Kubernetes through Connect Gateway"
  type        = string
}
