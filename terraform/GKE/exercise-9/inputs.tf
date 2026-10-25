variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "node_count" {
  description = "Nodes per cluster"
  type        = number
  default     = 1
}