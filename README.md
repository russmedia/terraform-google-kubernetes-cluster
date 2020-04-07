# Overview
GKE Kubernetes module with node pools submodule


![Kuberntes diagram on GKE](images/diagram.png)

Table of contents
=================

   * [Overview](#overview)
   * [Requirements](#requirements)
   * [Table of contents](#table-of-contents)
      * [1. Features](#1-features)
      * [2. Usage](#2-usage)
         * [cluster with default node pool on preemptible](#cluster-with-default-node-pool-on-preemptible)
         * [cluster with explicit definition of node pools (optional)](#cluster-with-explicit-definition-of-node-pools-optional)
         * [multiple clusters](#multiple-clusters)
         * [add nat module (optional)](#add-nat-module-optional)
         * [using an existing or creating a new vpc network](#using-an-existing-or-creating-a-new-vpc-network)
         * [subnetworks](#subnetworks)
         * [zonal and regional clusters](#zonal-and-regional-clusters)
         * [cloud nat](#cloud-nat)
      * [3. Migration from 1.x to 2.x ](#3-migration)
      * [5. Authors](#4-authors)
      * [6. License](#5-license)
      * [7. Acknowledgments](#6-acknowledgments)

# Requirements
Please use google provider version = "~> 3.14"

If you need more control with versioning of your cluster, it is advised to specify "min_master_version" and "version" in node-pools. Otherwise GKE will be using default version which might change in near future.

# Compatibility
This module is meant for use with Terraform 0.12. If you haven't upgraded and need a Terraform 0.11.x-compatible version of this module, the last released version intended for Terraform 0.11.x is 3.0.0.

## 1. Features

- multiple node pools with node number multiplied by defined zones
- node pools with autoscaling enabled (scale to 0 nodes available)
- node pools with preemptible instances
- ip_allocation_policy for exposing nodes/services/pods in VPC
- tested with NAT module
- configurable node pools oauth scopes (global per all node pools)

## 2. Usage

### cluster with default node pool on preemptible
```hcl
module "primary-cluster" {
  name                   = terraform.workspace
  source                 = "russmedia/kubernetes-cluster/google"
  version                = "4.0.0"
  region                 = var.google_region
  zones                  = var.google_zones
  project                = var.project
  environment            = terraform.workspace 
  min_master_version     = var.master_version
}
```

### cluster with explicit definition of node pools (optional)

```hcl
module "primary-cluster" {
  name                   = "my-cluster"
  source                 = "russmedia/kubernetes-cluster/google"
  version                = "4.0.0"
  region                 = var.google_region
  zones                  = var.google_zones
  project                = var.project
  environment            = terraform.workspace
  min_master_version     = var.master_version
  node_pools             = var.node_pools
}
```

and in variables:

```hcl
node_pools = [
  {
    name                = "default-pool"
    initial_node_count  = 1
    min_node_count      = 1
    max_node_count      = 1
    version             = "1.14.10-gke.34"
    image_type          = "COS"
    machine_type        = "n1-standard-1"
    preemptible         = true
    tags                = "tag1 nat"
  },
]
```
**Note: at least one node pool must have `initial_node_count` > 0.**

###  multiple clusters

Due to current limitations with depends_on feature and modules it is advised to create vpc network separately and use it when defining modules, i.e: 

```hcl
resource "google_compute_network" "default" {
  name                    = terraform.workspace
  auto_create_subnetworks = "false"
  project                 = var.project
}
```

```hcl
module "primary-cluster" {
  name        = "primary-cluster"
  source      = "russmedia/kubernetes-cluster/google"
  version     = "4.0.0"
  region      = var.google_region
  zones       = var.google_zones
  project     = var.project
  environment = terraform.workspace
  network     = google_compute_network.default.name
}
```

```hcl
module "secondary-cluster" {
  name                                 = "secondary-cluster"
  source                               = "russmedia/kubernetes-cluster/google"
  version                              = "4.0.0"
  region                               = var.google_region
  zones                                = var.google_zones
  project                              = var.project
  environment                          = terraform.workspace
  network                              = google_compute_network.default.name
  nodes_subnet_ip_cidr_range           = "10.101.0.0/24"
  nodes_subnet_container_ip_cidr_range = "172.21.0.0/16"
  nodes_subnet_service_ip_cidr_range   = "10.201.0.0/16"
}
```
**Note: secondary clusters need to have nodes_subnet_ip_cidr_range nodes_subnet_container_ip_cidr_range and nodes_subnet_service_ip_cidr_range defined, otherwise you will run into IP conflict. Also only one cluster can have nat_enabled set to 'true'.**

### add nat module (optional and depreciated - please use build in nat option - variable "nat_enabled")

Adding NAT module for outgoing Kubernetes IP:
```hcl
module "nat" {
  source     = "github.com/GoogleCloudPlatform/terraform-google-nat-gateway?ref=1.2.0"
  region     = var.google_region
  project    = var.project
  network    = terraform.workspace
  subnetwork = "${terraform.workspace}-nodes-subnet"
  tags       = ["nat-${terraform.workspace}"]
}
```

Note: remember to add tag `nat-${terraform.workspace}` to primary cluster tags and node pools so NAT module can open routing for nodes.

### using an existing or creating a new vpc network

Variable "network" is controling network creation. 
- when left empty (by default `network=""`) - terraform will create a vpc network - network name will be equal to `${terraform.workspace}`.
- when we define a name - this network **must already exist** within the project - terraform will create a subnetwork within defined network and place the cluster in it.

### subnetworks

Terraform always creates a subnetwork. The subnetwork name is taken from a pattern: `${terraform.workspace}-${var.name}-nodes-subnet`. If you already have a subnetwork and you would like to keep the name - please define the "subnetwork_name" variable.

- we define a subnetwork nodes CIDR using `nodes_subnet_ip_cidr_range` variable - terraform will fail with conflict if you use existing netmask
- we define kubernetes pods CIDR using `nodes_subnet_container_ip_cidr_range` variable
- we define kubernetes service CIDR using `nodes_subnet_service_ip_cidr_range` variable

### zonal and regional clusters

- Zonal clusters: 
A zonal cluster runs in one or more compute zones within a region. A multi-zone cluster runs its nodes across two or more compute zones within a single region. Zonal clusters run a single cluster master.
**Important** zonal clusters from version 3.0.0 are using nodes only in the zone of the master. This is changed due to new nodes behavior on google cloud. Nodes in other zones can no longer register to cluster in a different zone.
- Regional cluster:
A regional cluster runs three cluster masters across three compute zones, and runs nodes in two or more compute zones.

Regional clusters are still in beta, please use with caution. You can enable it by setting variable "regional_cluster" to true.
**Warning - possible data loss!** - changing this setting on a running cluster will force you to recreate it. 


### cloud nat

You can configure your cluster to sit behind nat, and have the same static external IP shared between pods. You can enable it by setting variable "nat_enabled" to true

**Warning - possible data loss!** - changing this setting on a running cluster will force you to recreate it. 

## 3. Migration

To migrate from `1.x.x` module version to `2.x.x` follow these steps:

- Remove `tags` property -> it is included now in `node_pools` map.
- Remove `node_version` property -> it is included now in `node_pools` map.
- Add `initial_node_count` to all node pools -> changing the previous value will recreate the node pool.
- Add `network` with existing network name.
- Add `subnetwork_name` with existing subnetwork name.
- Add `use_existing_terraform_network` set to `true` if network was created by this module.

Important note: when upgrading, default pool will be deleted. Before migration, please extend size of non-default pools to be able to schedule all applications without the default node pool.

## 4. Authors

- [Eryk Zalejski](https://github.com/ezalejski)

- [Filip Haftek](https://github.com/filiphaftek)

- [Christoph Rosse](https://github.com/gries)

## 5. License

This project is licensed under the MIT License - see the LICENSE.md file for details.
Copyright (c) 2018 Russmedia GmbH.

## 6. Acknowledgments

- [Konrad Černý](https://github.com/rokerkony)