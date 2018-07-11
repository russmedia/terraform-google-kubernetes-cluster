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

variable "initial_image_type" {
  default     = "COS"
  description = "Initial worker pool vm image"
}

variable "min_master_version" {
  default     = "1.10.4-gke.2"
  description = "Kubernetes master version"
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

variable "node_version" {
  default     = "1.10.4-gke.2"
  description = "Kubernetes worker version"
}

variable "node_pools" {
  type = "list"

  default = [
    {
      name           = "additional-pool"
      min_node_count = 1
      max_node_count = 1
      version        = "1.10.4-gke.2"
      image_type     = "COS"
      machine_type   = "n1-standard-1"
      preemptible    = false
      tags           = "additional-pool worker"
    },
  ]

  description = <<EOF
    Attributes of node pool:
      - name
      - min_node_count [number]
      - max_node_count [number]
      - version [Kubernetes worker version]
      - image_type
      - machine_type
      - preemptible [bool]
      - tags [space separated tags]
  EOF
}
