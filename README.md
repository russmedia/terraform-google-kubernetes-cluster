# terraform-google-kubernetes-cluster
GKE Kubernetes module with node pools submodule

![Kuberntes diagram on GKE](images/diagram.png)

## 1. Features

- basic node pool with node number multiplied by defined zones
- additional node pools with node number multiplied by defined zones
- node pools with autoscaling enabled
- ip_allocation_policy for exposing nodes/services/pods in VPC
- tested with NAT module

## 2. Usage:

a) cluster with one additional pool
```hcl
module "primary-cluster" {
  name                   = "${terraform.workspace}"
  source                 = "github.com/russmedia/terraform-google-kubernetes-cluster?ref=0.0.1"
  region                 = "${var.google_region}"
  zones                  = "${var.google_zones}"
  project                = "${var.project}"
  environment            = "${terraform.workspace}"
  tags                   = ["nat-${terraform.workspace}"]
  node_version           = "${var.node_version}"
  min_master_version     = "${var.master_version}"
}
```

b) cluster with explicit definition of additional node pools (optional)

```hcl
module "primary-cluster" {
  name                   = "${terraform.workspace}"
  source                 = "github.com/russmedia/terraform-google-kubernetes-cluster?ref=0.0.1"
  region                 = "${var.google_region}"
  zones                  = "${var.google_zones}"
  project                = "${var.project}"
  environment            = "${terraform.workspace}"
  tags                   = ["nat-${terraform.workspace}"]
  node_version           = "${var.node_version}"
  min_master_version     = "${var.master_version}"
  node_pools             = "${var.node_pools}"
}
```

and in variables:

```hcl
node_pools = [
  {
    name            = "additional-pool"
    min_node_count  = 1
    max_node_count  = 2
    image_type      = "COS"
    machine_type    = "n1-standard-1"
    preemptible     = false
    tags            = "tag1 tag2"
  },
]
```

c) add nat module (optional)

Adding NAT module to for outgoing Kubernetes IP:
```hcl
module "nat" {
  source     = "github.com/GoogleCloudPlatform/terraform-google-nat-gateway?ref=1.1.8"
  region     = "${var.google_region}"
  project    = "${var.project}"
  network    = "${terraform.workspace}"
  subnetwork = "${terraform.workspace}-nodes-subnet"
  tags       = ["nat-${terraform.workspace}"]
}
```

## 3. Authors

- [Eryk Zalejski](https://github.com/ezalejski)

- [Filip Haftek](https://github.com/filiphaftek)

- [Christoph Rosse](https://github.com/gries)

## 4. License

This project is licensed under the MIT License - see the LICENSE.md file for details.
Copyright (c) 2018 Russmedia GmbH.

## 4. Acknowledgments

- [Konrad Černý](https://github.com/rokerkony)