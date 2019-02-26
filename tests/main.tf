module "primary-cluster" {
  name = "primary-cluster"

  source = "../."
  region = "${var.region}"

  zones       = "${var.zones}"
  project     = "${var.project}"
  environment = "${terraform.workspace}"

  min_master_version = "1.11.7-gke.6"
  network = "${google_compute_network.main.name}"
}

resource "google_compute_network" "main" {
  name                    = "${terraform.workspace}-manual"
  auto_create_subnetworks = "false"
  project                 = "${var.project}"
}