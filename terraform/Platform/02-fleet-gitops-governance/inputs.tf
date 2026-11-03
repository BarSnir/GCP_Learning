variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "pca-certifciation"
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
  default     = "gitops-network"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "gitops-subnet"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.20.0.0/20"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "gitops-gke"
}

variable "membership_name" {
  description = "Fleet membership name"
  type        = string
  default     = "gitops-gke-membership"
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-small"
}

variable "git_repo" {
  description = "Public Git repository used by Config Sync"
  type        = string
  default     = "https://github.com/BarSnir/GCP_Learning.git"
}

variable "git_branch" {
  description = "Git branch used by Config Sync"
  type        = string
  default     = "main"
}

variable "policy_dir" {
  description = "Directory inside the Git repository used by Config Sync"
  type        = string
  default     = "terraform/Platform/02-fleet-gitops-governance/config-sync"
}
