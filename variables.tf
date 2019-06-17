variable "name" {
  description = "Kubernetes cluster name"
}

variable "project" {
  description = "Google Cloud project name"
}

variable "use_existing_terraform_network" {
  description = "set to true if you are upgrading from older versions and you would like to keep the network created by terraform"
  default     = false
}

variable "network" {
  description = <<EOF
  Network to create the cluster in 
    - module will create a network based on terraform workspace name if this variable is empty
    - if we define a network here it needs to exist already
EOF

  default = ""
}

variable "subnetwork_name" {
  description = <<EOF
  Subnetwork to create the cluster in 
    - module will create a subnetwork based on terraform workspace and cluster name if this variable is empty
    - if we define a network here it needs to have uniqe name 
EOF

  default = ""
}

variable "nat_enabled" {
  description = "Enable Cloud Nat Module for cluster"
  default     = false
}

variable "region" {
  description = "Kubernetes cluster region"
}

variable "zones" {
  type        = "list"
  description = "Zones for Kubernetes workers"
}

variable "regional_cluster" {
  default     = false
  description = "Set to `true` to create regional cluster"
}

variable "environment" {
  description = "Environment label"
}

variable "min_master_version" {
  default     = ""
  description = "Kubernetes master version"
}

variable "master_subnet_ip_cidr_range" {
  default     = "10.10.0.0/28"
  description = "Cidr range for Kubernetes masters - needed for regional clusters"
}

variable "nodes_subnet_ip_cidr_range" {
  default     = "10.100.0.0/24"
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
      version            = ""
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
      - custom_label_keys [space separated tags, must match the number of custom_label_values] 
      - custom_label_values [space separated tags, must match the number of custom_label_keys] 
  EOF
}
