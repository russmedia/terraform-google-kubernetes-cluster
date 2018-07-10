variable "name" {
  description = "Kubernetes cluster name"
}

variable "project" {
  description = "Google Cloud project name"
}

variable "region" {
  description = "Kubernetes cluster region"
}

variable "zones" {
  type        = "list"
  description = "Zones for Kubernetes workers"
}

variable "tags" {
  type        = "list"
  description = "Kubernetes workers tags"
  default     = []
}

variable "environment" {
  description = "Environment label"
}

variable "initial_node_count" {
  default     = 1
  description = "Initial node count per zone"
}

variable "initial_machine_type" {
  default     = "g1-small"
  description = "Initial vm type"
}

variable "node_pool_count" {
  default     = 1
  description = "Additional pool node count per zone"
}

variable "node_pool_machine_type" {
  default     = "n1-standard-1"
  description = "Additional worker pool vm type"
}

variable "min_master_version" {
  default     = "1.8.12-gke.1"
  description = "Kubernetes master version"
}

variable "node_version" {
  default     = "1.8.12-gke.1"
  description = "Kubernetes worker version"
}

variable "nodes_subnet_ip_cidr_range" {
  default     = "10.101.0.0/24"
  description = "Cidr range for Kubernetes workers"
}

variable "nodes_subnet_container_ip_cidr_range" {
  default     = "172.20.0.0/16"
  description = "Cidr range for Kubernetes containers"
}

variable "nodes_subnet_service_ip_cidr_range" {
  default     = "10.200.0.0/16"
  description = "Cidr range for Kubernetes services"
}
