output "cluster_name" {
  value = google_container_cluster.primary.name
}
 
output "cluster_endpoint" {
  value     = google_container_cluster.primary.endpoint
  sensitive = true
}
 
output "cluster_ca_certificate" {
  value     = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive = true
}
 
output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}
 
output "node_service_account" {
  value = google_service_account.gke_node_sa.email
}
 
output "workload_identity_pool" {
  value = "${var.project_id}.svc.id.goog"
}
 
output "vpc_name" {
  value = google_compute_network.gke_vpc.name
}
 
output "subnet_name" {
  value = google_compute_subnetwork.gke_subnet.name
}
