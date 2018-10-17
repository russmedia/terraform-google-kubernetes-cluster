resource "google_container_cluster" "primary" {
  name = "${var.name}"
  zone = "${var.region}-${var.zones[0]}"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? terraform.workspace : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.1.range_name}"
  }

  additional_zones = [
    "${formatlist("%s-%s", var.region, slice(var.zones,1,length(var.zones)))}",
  ]

  lifecycle {
    ignore_changes = ["subnetwork"]
  }

  initial_node_count       = 1
  remove_default_node_pool = true
}

module "node-pool" {
  source       = "./modules/kubernetes_node_pools"
  region       = "${var.region}"
  zones        = ["${var.zones}"]
  project      = "${var.project}"
  environment  = "${terraform.workspace}"
  cluster_name = "${google_container_cluster.primary.name}"
  node_pools   = "${var.node_pools}"
}

resource "google_compute_network" "default" {
  count                   = "${var.network == "" ? 1 : 0}"
  name                    = "${terraform.workspace}"
  auto_create_subnetworks = "false"
  project                 = "${var.project}"
}

# Subnet for cluster nodes
resource "google_compute_subnetwork" "nodes-subnet" {
  name          = "${terraform.workspace}-${var.name}-nodes-subnet"
  ip_cidr_range = "${var.nodes_subnet_ip_cidr_range}"
  network       = "${var.network == "" ? terraform.workspace : var.network}"
  region        = "${var.region}"
  project       = "${var.project}"

  secondary_ip_range {
    range_name    = "${terraform.workspace}-container-range-1"
    ip_cidr_range = "${var.nodes_subnet_container_ip_cidr_range}"
  }

  secondary_ip_range {
    range_name    = "${terraform.workspace}-service-range-1"
    ip_cidr_range = "${var.nodes_subnet_service_ip_cidr_range}"
  }
}
