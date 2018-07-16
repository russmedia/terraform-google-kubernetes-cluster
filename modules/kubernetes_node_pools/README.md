# terraform-google-kubernetes-cluster
GKE Kubernetes node pools submodule

1. Usage:

```hcl
module "node-pool" {
  source       = "./modules/kubernetes_node_pools"
  node_version = "${var.node_version}"
  region       = "${var.region}"
  zones        = ["${var.zones}"]
  project      = "${var.project}"
  environment  = "${terraform.workspace}"
  cluster_name = "${var.cluster_name}"
  node_pools   = "${var.node_pools}"
}
```

where `node_pools` is in format:

```hcl
node_pools = [
  {
    name           = "additional-pool"
    min_node_count = 1
    max_node_count = 1
    version        = "1.10.4-gke.2"
    image_type     = "COS"
    machine_type   = "n1-standard-1"
    preemptible    = false
    tags           = "additional-pool worker"
  },
]
```
