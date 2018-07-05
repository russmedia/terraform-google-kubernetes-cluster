# terraform-google-kubernetes-cluster
GKE Kubernetes module with node pools submodule

![Kuberntes diagram on GKE](images/diagram.png)

1. Usage:

```hcl
module "primary-cluster" {
  name                   = "${terraform.workspace}"
  source                 = "github.com/russmedia/terraform-google-kubernetes-cluster?ref=1.0.0"
  region                 = "${var.google_region}"
  zones                  = "${var.google_zones}"
  project                = "${var.project}"
  environment            = "${terraform.workspace}"
  tags                   = ["nat-${terraform.workspace}"]
  node_pool_count        = "${var.node_pool_count}"
  node_version           = "${var.node_version}"
  node_pool_machine_type = "${var.node_pool_machine_type}"
  min_master_version     = "${var.master_version}"
}
```