variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for all resources"
  type        = string
  default     = "europe-west1"
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Regular (non-proxy-only) subnetwork in the region - used by the backend VMs, the client VM, and the internal frontend IP"
  type        = string
  default     = "default"
}

variable "proxy_subnet_cidr" {
  description = "CIDR range for the dedicated proxy-only subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "machine_type" {
  description = "Machine type for the web instance template and the client VM"
  type        = string
  default     = "e2-micro"
}

variable "target_size" {
  description = "Number of instances in the web MIG"
  type        = number
  default     = 2
}

variable "zone" {
  description = "Google Cloud zone"
  type        = string
  default     = "europe-west1-b"
}

variable "probe_destination_ip" {
  description = "Internal IP of one of the web MIG's VMs, for the connectivity test (fill in after the MIG creates instances, e.g. via `gcloud compute instances list`)"
  type        = string
  default     = "10.132.0.58"
}