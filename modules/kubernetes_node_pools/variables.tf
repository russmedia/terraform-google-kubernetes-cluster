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

variable "environment" {
  description = "Environment node label"
}

variable "cluster_name" {
  default     = ""
  description = "Kubernetes cluster name"
}
