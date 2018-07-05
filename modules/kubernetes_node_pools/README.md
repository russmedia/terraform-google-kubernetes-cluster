# terraform-google-kubernetes-cluster
GKE Kubernetes node pool submodule

1. Usage:

```hcl
module "node-pool" {
  name         = "${var.name}"
  source       = "./modules/kubernetes_node_pools"
  node_count   = "${var.node_pool_count}"
  node_version = "${var.node_version}"
  region       = "${var.region}"
  zones        = ["${var.zones}"]
  project      = "${var.project}"
  environment  = "${terraform.workspace}"
  machine_type = "${var.node_pool_machine_type}"
  cluster_name = "${google_container_cluster.primary.name}"
  tags         = "${var.tags}"
}
```
