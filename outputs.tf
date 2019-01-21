# The following outputs allow authentication and connectivity to the GKE Cluster.
output "primary_cluster_id" {
  value = "${coalesce(join("", google_container_cluster.primary.*.id),join("", google_container_cluster.primary-regional.*.id))}"
}

output "master_ip" {
  value = "${coalesce(join("", google_container_cluster.primary.*.endpoint),join("", google_container_cluster.primary-regional.*.endpoint))}"
}
