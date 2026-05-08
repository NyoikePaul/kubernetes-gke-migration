resource "google_container_cluster" "primary" {
  name     = "gke-migration-cluster"
  location = var.region

  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.main.name

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"

    services_secondary_range_name = "gke-services"


private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Keep endpoint public for easy access, but nodes private
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "main-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    service_account = google_service_account.gke_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
