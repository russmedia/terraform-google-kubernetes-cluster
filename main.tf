resource "google_container_cluster" "primary" {
  name = "${var.name}"

  zone  = "${var.region}-${var.zones[0]}"
  count = "${var.regional_cluster ||  var.nat_enabled ? 0 : 1 }"

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

resource "google_container_cluster" "primary-regional" {
  name  = "${var.name}"
  count = "${var.regional_cluster && !var.nat_enabled  ? 1 : 0 }"

  region = "${var.region}"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? terraform.workspace : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  private_cluster_config {
    enable_private_nodes    = "false"
    enable_private_endpoint = "false"
    master_ipv4_cidr_block  = "${var.master_subnet_ip_cidr_range}"
  }

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

resource "google_container_cluster" "primary-nat" {
  name = "${var.name}"

  zone  = "${var.region}-${var.zones[0]}"
  count = "${!var.regional_cluster && var.nat_enabled  ? 1 : 0 }"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? terraform.workspace : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  private_cluster_config {
    master_ipv4_cidr_block = "${var.master_subnet_ip_cidr_range}"
  }

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

resource "google_container_cluster" "primary-regional-nat" {
  name  = "${var.name}"
  count = "${var.regional_cluster && var.nat_enabled ? 1 : 0 }"

  region = "${var.region}"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? terraform.workspace : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  private_cluster_config {
    enable_private_nodes    = "true"
    enable_private_endpoint = "true"
    master_ipv4_cidr_block  = "${var.master_subnet_ip_cidr_range}"
  }

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
  source           = "./modules/kubernetes_node_pools"
  region           = "${coalesce(var.region, join("",google_container_cluster.primary-regional.*.region))}"
  zones            = ["${var.zones}"]
  project          = "${var.project}"
  environment      = "${terraform.workspace}"
  cluster_name     = "${var.name}"
  node_pools       = "${var.node_pools}"
  regional_cluster = "${var.regional_cluster}"
}

resource "google_compute_network" "default" {
  count                   = "${var.network == "" ? 1 : 0}"
  name                    = "${terraform.workspace}"
  auto_create_subnetworks = "false"
  project                 = "${var.project}"
}

locals {
  subnetwork_name = "${terraform.workspace}-${var.name}-nodes-subnet"
}

# Subnet for cluster nodes
resource "google_compute_subnetwork" "nodes-subnet" {
  depends_on    = ["google_compute_network.default"]
  name          = "${var.subnetwork_name == "" ? local.subnetwork_name : var.subnetwork_name}"
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

resource "google_compute_router" "router" {
  count   = "${var.nat_enabled ? 1 : 0}"
  name    = "router"
  region  = "${var.region}"
  network = "${var.network == "" ? terraform.workspace : var.network}"
}

resource "google_compute_address" "address" {
  count  = "${var.nat_enabled ? 1 : 0}"
  name   = "nat-external-address-${count.index}"
  region = "${var.region}"
}

resource "google_compute_router_nat" "advanced-nat" {
  count                              = "${var.nat_enabled ? 1 : 0}"
  name                               = "nat-1"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = ["${google_compute_address.address.*.self_link}"]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                     = "${google_compute_subnetwork.nodes-subnet.self_link}"
    source_ip_ranges_to_nat  = ["LIST_OF_SECONDARY_IP_RANGES"]
    secondary_ip_range_names = ["${google_compute_subnetwork.nodes-subnet.secondary_ip_range.0.range_name}", "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.1.range_name}"]
  }
}
