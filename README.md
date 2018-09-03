# terraform-google-kubernetes-cluster
GKE Kubernetes module with node pools submodule

![Kuberntes diagram on GKE](images/diagram.png)

## 1. Features

- basic node pool with node number multiplied by defined zones
- additional node pools with node number multiplied by defined zones
- node pools with autoscaling enabled (scale to 0 nodes available)
- node pools with preemptible instances
- ip_allocation_policy for exposing nodes/services/pods in VPC
- tested with NAT module

## 2. Usage:

a) cluster with one additional pool
```hcl
module "primary-cluster" {
  name                   = "${terraform.workspace}"
  source                 = "github.com/russmedia/terraform-google-kubernetes-cluster?ref=1.4.0"
  region                 = "${var.google_region}"
  zones                  = "${var.google_zones}"
  project                = "${var.project}"
  environment            = "${terraform.workspace}"
  tags                   = ["nat-${terraform.workspace}"]
  min_master_version     = "${var.master_version}"
}
```

b) cluster with explicit definition of additional node pools (optional)

```hcl
module "primary-cluster" {
  name                   = "${terraform.workspace}"
  source                 = "github.com/russmedia/terraform-google-kubernetes-cluster?ref=1.4.0"
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
    version         = "1.10.6-gke.2"
    image_type      = "COS"
    machine_type    = "n1-standard-1"
    preemptible     = false
    tags            = "tag1 nat"
  },
]
```

c) add nat module (optional)

Adding NAT module for outgoing Kubernetes IP:
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

Note: remember to add tag `nat-${terraform.workspace}` to primary cluster tags and node pools so NAT module can open routing for nodes.

d) using an existing or creating a new vpc network.

Variable "network" is controling network creation. 
- when left empty (by default `network=""`) - terraform will create a vpc network - network name will be equal to `${terraform.workspace}`.
- when we define a name - this network **must already exist** within the project - terraform will create a subnetwork within defined network and place the cluster in it.

e) subnetworks

Terraform always creates a subnetwork. The subnetwork name is taken from a pattern: `${terraform.workspace}-nodes-subnet`.

- we define a subnetwork nodes CIDR using `nodes_subnet_ip_cidr_range` variable - terraform will fail with conflict if you use existing netmask
- we define kubernetes pods CIDR using `nodes_subnet_container_ip_cidr_range` variable
- we define kubernetes service CIDR using `nodes_subnet_service_ip_cidr_range` variable

## 3. Authors

- [Eryk Zalejski](https://github.com/ezalejski)

- [Filip Haftek](https://github.com/filiphaftek)

- [Christoph Rosse](https://github.com/gries)

## 4. License

This project is licensed under the MIT License - see the LICENSE.md file for details.
Copyright (c) 2018 Russmedia GmbH.

## 4. Acknowledgments

- [Konrad Černý](https://github.com/rokerkony)