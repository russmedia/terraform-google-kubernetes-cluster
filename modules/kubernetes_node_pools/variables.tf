variable "name" {
  description = "Node pool name"
}

variable "project" {
  description = "Google Cloud project name"
}

variable "region" {
  description = "Node pool region"
}

variable "zones" {
  type        = "list"
  description = "Zones for node pool"
}

variable "tags" {
  type        = "list"
  description = "Node pool vm's tags"
  default     = []
}

variable "environment" {
  description = "Environment node label"
}

variable "node_count" {
  default     = 1
  description = "Node count per zone"
}

variable "node_version" {
  description = "Kubernetes worker version"
}

variable "machine_type" {
  default     = "n1-standard-1"
  description = "Node pool vm type"
}

variable "cluster_name" {
  default     = ""
  description = "Kubernetes cluster name"
}
