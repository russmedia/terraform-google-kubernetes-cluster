resource "google_container_cluster" "primary" {
  name               = "${var.name}"
  zone               = "${var.region}-${var.zones[0]}"
  initial_node_count = "${var.initial_node_count}"
  min_master_version = "${var.min_master_version}"
  network            = "${google_compute_network.default.self_link}"
  enable_legacy_abac = "false"
  node_version       = "${var.node_version}"

  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"

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

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    machine_type = "${var.initial_machine_type}"
    image_type   = "${var.initial_image_type}"

    labels {
      environment = "${var.environment}"
    }

    tags = "${var.tags}"
  }
}

module "node-pool" {
  source       = "./modules/kubernetes_node_pools"
  node_version = "${var.node_version}"
  region       = "${var.region}"
  zones        = ["${var.zones}"]
  project      = "${var.project}"
  environment  = "${terraform.workspace}"
  cluster_name = "${google_container_cluster.primary.name}"
  node_pools   = "${var.node_pools}"
}

resource "google_compute_network" "default" {
  name                    = "${terraform.workspace}"
  auto_create_subnetworks = "false"
}

# Subnet for cluster nodes
resource "google_compute_subnetwork" "nodes-subnet" {
  name          = "${terraform.workspace}-nodes-subnet"
  ip_cidr_range = "${var.nodes_subnet_ip_cidr_range}"
  network       = "${google_compute_network.default.self_link}"
  region        = "${var.region}"

  secondary_ip_range {
    range_name    = "${terraform.workspace}-container-range-1"
    ip_cidr_range = "${var.nodes_subnet_container_ip_cidr_range}"
  }

  secondary_ip_range {
    range_name    = "${terraform.workspace}-service-range-1"
    ip_cidr_range = "${var.nodes_subnet_service_ip_cidr_range}"
  }
}
