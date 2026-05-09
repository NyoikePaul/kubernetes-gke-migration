# System Node Pool (Stable/Internal)
resource "google_container_node_pool" "system_nodes" {
  name       = "system-pool"
  cluster    = google_container_cluster.primary.id
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels = {
      role = "system"
    }
  }
}

# Workload Node Pool (For your actual Apps)
resource "google_container_node_pool" "workload_nodes" {
  name       = "workload-pool"
  cluster    = google_container_cluster.primary.id
  initial_node_count = 2

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    machine_type = "e2-standard-2"
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels = {
      role = "workload"
    }
  }
}
