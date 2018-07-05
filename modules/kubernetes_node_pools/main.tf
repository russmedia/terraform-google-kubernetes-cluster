resource "google_container_node_pool" "node_pool" {
  name       = "${var.name}"
  zone       = "${var.region}-${var.zones[0]}"
  cluster    = "${var.cluster_name}"
  node_count = "${var.node_count}"
  version    = "${var.node_version}"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    machine_type = "${var.machine_type}"

    labels {
      environment = "${var.environment}"
    }

    tags = "${var.tags}"
  }
}
