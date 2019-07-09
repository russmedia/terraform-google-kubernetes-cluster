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
  scopes       = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
  ]
}
```

where `node_pools` is in format:

```hcl
node_pools = [
  {
    name               = "additional-pool"
    initial_node_count = 1
    min_node_count     = 1
    max_node_count     = 1
    version            = "1.10.7-gke.6"
    image_type         = "COS"
    machine_type       = "n1-standard-1"
    preemptible        = false
    tags               = "additional-pool worker"
  },
]
```
