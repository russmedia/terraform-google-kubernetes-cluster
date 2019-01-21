# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${coalesce(join("", google_container_cluster.primary.*.master_auth.0.client_certificate),join("", google_container_cluster.primary-regional.*.master_auth.0.client_certificate))}"
}

output "client_key" {
  value = "${coalesce(join("", google_container_cluster.primary.*.master_auth.0.client_key),join("", google_container_cluster.primary-regional.*.master_auth.0.client_key))}"
}

output "cluster_ca_certificate" {
  value = "${coalesce(join("", google_container_cluster.primary.*.master_auth.0.cluster_ca_certificate),join("", google_container_cluster.primary-regional.*.master_auth.0.cluster_ca_certificate))}"
}

output "primary_cluster_id" {
  value = "${coalesce(join("", google_container_cluster.primary.*.id),join("", google_container_cluster.primary-regional.*.id))}"
}

output "master_ip" {
  value = "${coalesce(join("", google_container_cluster.primary.*.endpoint),join("", google_container_cluster.primary-regional.*.endpoint))}"
}
