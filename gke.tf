resource "google_container_cluster" "primary" {
  # ... existing config (name, location, network) ...

  # Enterprise Feature: Workload Identity (Allows Pods to assume IAM roles safely)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enterprise Feature: Release Channels (Automated version management)
  release_channel {
    channel = "REGULAR"
  }

  # Security: Shielded Nodes
  enable_shielded_nodes = true

  # Optimization: Cost Management
  cost_management_config {
    enabled = true
  }
}
