# terraform-google-kubernetes-cluster
GKE Kubernetes module with node pools submodule

![Kuberntes diagram on GKE](images/diagram.png)

## 1. Features

- basic node pool with node number multiplied by defined zones
- additional node pool with node number multiplied by defined zone
- ip_allocation_policy for exposing nodes/services/pods in VPC
- tested with NAT module

## 2. Usage:

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