variable "name" {
  description = "Kubernetes cluster name"
}

variable "project" {
  description = "Google Cloud project name"
}

variable "network" {
  description = <<EOF
  Network to create the cluster in 
    - module will create a network based on terraform workspace name if this variable is empty
    - if we define a network here it needs to exist already
EOF

  default = ""
}

variable "region" {
  description = "Kubernetes cluster region"
}

variable "zones" {
  type        = "list"
  description = "Zones for Kubernetes workers"
}

variable "environment" {
  description = "Environment label"
}

variable "min_master_version" {
  default     = "1.10.7-gke.6"
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

variable "node_pools" {
  type = "list"

  default = [
    {
      name               = "default-pool"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 3
      version            = "1.10.7-gke.6"
      image_type         = "COS"
      machine_type       = "n1-standard-1"
      preemptible        = true
      tags               = "default-pool worker"
    },
  ]

  description = <<EOF
    Attributes of node pool:
      - name
      - initial_node_count [number]
      - min_node_count [number]
      - max_node_count [number]
      - version [Kubernetes worker version]
      - image_type
      - machine_type
      - preemptible [bool]
      - tags [space separated tags]
  EOF
}
