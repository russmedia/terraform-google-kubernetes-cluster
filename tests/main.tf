module "primary-cluster" {
  name = "primary-cluster"

  source = "../."
  region = "${var.region}"

  zones       = "${var.zones}"
  project     = "${var.project}"
  environment = "${terraform.workspace}"

  min_master_version = "1.11.7-gke.6"
  network            = "default-manual"
}
