locals {
  default_labels = {
    environment = var.environment
  }
}

resource "google_container_node_pool" "node_pool" {
  name               = var.node_pools[count.index]["name"]
  count              = var.regional_cluster ? 0 : length(var.node_pools)
  location           = "${var.region}-${var.zones[0]}"
  cluster            = var.cluster_name
  version            = var.node_pools[count.index]["version"]
  project            = var.project
  initial_node_count = var.node_pools[count.index]["initial_node_count"]

  autoscaling {
    min_node_count = var.node_pools[count.index]["min_node_count"]
    max_node_count = var.node_pools[count.index]["max_node_count"]
  }

  node_config {
    oauth_scopes = var.node_pools_scopes

    preemptible  = var.node_pools[count.index]["preemptible"]
    machine_type = var.node_pools[count.index]["machine_type"]
    image_type   = var.node_pools[count.index]["image_type"]

    labels = merge(
      local.default_labels,
      zipmap(
        split(
          " ",
          lookup(
            var.node_pools[count.index],
            "custom_label_keys",
            "environment",
          ),
        ),
        split(
          " ",
          lookup(
            var.node_pools[count.index],
            "custom_label_values",
            var.environment,
          ),
        ),
      ),
    )
    dynamic "taint" {
      for_each = lookup(var.node_pools[count.index], "no_execute_taint", false) ? var.no_execute_taint : []
      content {
        effect = taint.value["effect"]
        key    = taint.value["key"]
        value  = taint.value["value"]
      }
    }
    dynamic "taint" {
      for_each = lookup(var.node_pools[count.index], "no_schedule_taint", false) ? var.no_schedule_taint : []
      content {
        effect = taint.value["effect"]
        key    = taint.value["key"]
        value  = taint.value["value"]
      }
    }
    tags = split(" ", var.node_pools[count.index]["tags"])
  }
}

resource "google_container_node_pool" "node_pool_regional" {
  name               = var.node_pools[count.index]["name"]
  count              = var.regional_cluster ? length(var.node_pools) : 0
  location           = var.region
  cluster            = var.cluster_name
  version            = var.node_pools[count.index]["version"]
  project            = var.project
  initial_node_count = var.node_pools[count.index]["initial_node_count"]

  autoscaling {
    min_node_count = var.node_pools[count.index]["min_node_count"]
    max_node_count = var.node_pools[count.index]["max_node_count"]
  }

  node_config {
    oauth_scopes = var.node_pools_scopes

    preemptible  = var.node_pools[count.index]["preemptible"]
    machine_type = var.node_pools[count.index]["machine_type"]
    image_type   = var.node_pools[count.index]["image_type"]

    labels = merge(
      local.default_labels,
      zipmap(
        split(
          " ",
          lookup(
            var.node_pools[count.index],
            "custom_label_keys",
            "environment",
          ),
        ),
        split(
          " ",
          lookup(
            var.node_pools[count.index],
            "custom_label_values",
            var.environment,
          ),
        ),
      ),
    )
    dynamic "taint" {
      for_each = lookup(var.node_pools[count.index], "no_execute_taint", false) ? var.no_execute_taint : []
      content {
        effect = taint.value["effect"]
        key    = taint.value["key"]
        value  = taint.value["value"]
      }
    }
    dynamic "taint" {
      for_each = lookup(var.node_pools[count.index], "no_schedule_taint", false) ? var.no_schedule_taint : []
      content {
        effect = taint.value["effect"]
        key    = taint.value["key"]
        value  = taint.value["value"]
      }
    }
    tags = split(" ", var.node_pools[count.index]["tags"])
  }
}

