locals {
  network_name    = "${terraform.workspace}-${var.name}"
  subnetwork_name = "${terraform.workspace}-${var.name}-nodes-subnet"
}

resource "google_container_cluster" "primary" {
  name = "${var.name}"

  location = "${var.region}-${var.zones[0]}"
  count    = "${var.regional_cluster ||  var.nat_enabled ? 0 : 1 }"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? local.network_name : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.1.range_name}"
  }

  node_locations = [
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

  location = "${var.region}"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? local.network_name : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.1.range_name}"
  }

  node_locations = [
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

  location = "${var.region}-${var.zones[0]}"
  count    = "${!var.regional_cluster && var.nat_enabled  ? 1 : 0 }"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? local.network_name : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  private_cluster_config {
    enable_private_nodes    = "true"
    enable_private_endpoint = "false"
    master_ipv4_cidr_block  = "${var.master_subnet_ip_cidr_range}"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "world"
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.1.range_name}"
  }

  node_locations = [
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

  location = "${var.region}"

  min_master_version = "${var.min_master_version}"
  enable_legacy_abac = false

  network    = "${var.network == "" ? local.network_name : var.network}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"
  project    = "${var.project}"

  private_cluster_config {
    enable_private_nodes    = "true"
    enable_private_endpoint = "false"
    master_ipv4_cidr_block  = "${var.master_subnet_ip_cidr_range}"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "world"
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.nodes-subnet.secondary_ip_range.1.range_name}"
  }

  node_locations = [
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
  region           = "${coalesce(replace(join("",google_container_cluster.primary.*.zone), "-${var.zones[0]}", ""), replace(join("",google_container_cluster.primary-nat.*.zone), "-${var.zones[0]}", "") , join("",google_container_cluster.primary-regional.*.region), join("",google_container_cluster.primary-regional-nat.*.region))}"
  zones            = ["${var.zones}"]
  project          = "${var.project}"
  environment      = "${terraform.workspace}"
  cluster_name     = "${var.name}"
  node_pools       = "${var.node_pools}"
  regional_cluster = "${var.regional_cluster}"
}

resource "google_compute_network" "default" {
  count                   = "${var.network == "" || var.use_existing_terraform_network ? 1 : 0}"
  name                    = "${var.network == "" ? local.network_name : var.network}"
  auto_create_subnetworks = "false"
  project                 = "${var.project}"
}

# Subnet for cluster nodes
resource "google_compute_subnetwork" "nodes-subnet" {
  depends_on    = ["google_compute_network.default"]
  name          = "${var.subnetwork_name == "" ? local.subnetwork_name : var.subnetwork_name}"
  ip_cidr_range = "${var.nodes_subnet_ip_cidr_range}"
  network       = "${var.network == "" ? local.network_name : var.network}"
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
  name    = "${terraform.workspace}-${var.name}"
  region  = "${var.region}"
  network = "${var.network == "" ? element(concat(google_compute_network.default.*.name, list("")), count.index) : var.network}"
}

resource "google_compute_address" "address" {
  count  = "${var.nat_enabled ? 1 : 0}"
  name   = "${terraform.workspace}-${var.name}-nat-external-address"
  region = "${var.region}"
}

resource "google_compute_router_nat" "advanced-nat" {
  count                              = "${var.nat_enabled ? 1 : 0}"
  name                               = "${terraform.workspace}-${var.name}-nat"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = ["${google_compute_address.address.*.self_link}"]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
