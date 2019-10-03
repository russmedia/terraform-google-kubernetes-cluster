module "primary-cluster" {
  name        = "primary-cluster"
  source      = "../."
  region      = "${var.region}"
  zones       = "${var.zones}"
  project     = "${var.project}"
  environment = "${terraform.workspace}"

  # # this cluster is testing existing network
  # network = "${google_compute_network.main.name}"
}

module "primary-cluster-regional" {
  name        = "primary-cluster-regional"
  source      = "../."
  region      = "${var.region}"
  zones       = "${var.zones}"
  project     = "${var.project}"
  environment = "${terraform.workspace}"

  # this cluster is creating its own  network
  # network = "${google_compute_network.main.name}"
  master_subnet_ip_cidr_range = "10.11.0.0/28"

  nodes_subnet_ip_cidr_range           = "10.101.0.0/24"
  nodes_subnet_container_ip_cidr_range = "172.21.0.0/16"
  nodes_subnet_service_ip_cidr_range   = "10.201.0.0/16"

  #test with defined node pool (default node version)
  node_pools = [
    {
      name               = "additional-pool"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 1
      version            = ""
      image_type         = "COS"
      machine_type       = "n1-standard-1"
      preemptible        = false
      tags               = "additional-pool worker"
    },
  ]

  # this cluster will test regional setup
  regional_cluster = true
}

module "primary-cluster-regional-nat" {
  name                                 = "primary-cluster-regional-nat"
  source                               = "../."
  region                               = "${var.region}"
  zones                                = "${var.zones}"
  project                              = "${var.project}"
  environment                          = "${terraform.workspace}"
  network                              = "${google_compute_network.main.name}"
  master_subnet_ip_cidr_range          = "10.13.0.0/28"
  nodes_subnet_ip_cidr_range           = "10.103.0.0/24"
  nodes_subnet_container_ip_cidr_range = "172.23.0.0/16"
  nodes_subnet_service_ip_cidr_range   = "10.203.0.0/16"
  min_master_version                   = "${var.kube_version}"

  #test with defined node pool (specific version)
  node_pools = [
    {
      name               = "additional-pool"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 1
      version            = "${var.kube_version}"
      image_type         = "COS"
      machine_type       = "n1-standard-1"
      preemptible        = false
      tags               = "additional-pool worker"
    },
  ]

  node_pools_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]

  # this cluster is testing regional setup behind nat
  regional_cluster = true
  nat_enabled      = true
}

# this is a network to test creation with exisiting one
resource "google_compute_network" "main" {
  name                    = "${terraform.workspace}-manual"
  auto_create_subnetworks = "false"
  project                 = "${var.project}"
}
