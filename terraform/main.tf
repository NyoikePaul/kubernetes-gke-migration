###############################################################################
# terraform/main.tf
# Enterprise GKE Cluster — Private Cluster + Workload Identity + Node Pools
###############################################################################
 
terraform {
  required_version = ">= 1.6.0"
 
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
 
  # ── Remote state (uncomment and fill in your bucket) ─────────────────────
  # backend "gcs" {
  #   bucket  = "YOUR-TFSTATE-BUCKET"
  #   prefix  = "kubernetes-gke-migration/state"
  # }
}
 
provider "google" {
  project = var.project_id
  region  = var.region
}
 
provider "google-beta" {
  project = var.project_id
  region  = var.region
}
 
###############################################################################
# 1. NETWORKING — VPC + Subnets
###############################################################################
 
resource "google_compute_network" "gke_vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  description             = "Dedicated VPC for ${var.cluster_name}"
}
 
resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "${var.cluster_name}-subnet"
  ip_cidr_range            = var.node_cidr
  region                   = var.region
  network                  = google_compute_network.gke_vpc.id
  private_ip_google_access = true
 
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pod_cidr
  }
 
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.svc_cidr
  }
 
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
 
resource "google_compute_router" "gke_router" {
  name    = "${var.cluster_name}-router"
  region  = var.region
  network = google_compute_network.gke_vpc.id
}
 
resource "google_compute_router_nat" "gke_nat" {
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.gke_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
 
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
 
###############################################################################
# 2. SERVICE ACCOUNTS — Least-privilege Workload Identity
###############################################################################
 
resource "google_service_account" "gke_node_sa" {
  account_id   = "${var.cluster_name}-node-sa"
  display_name = "GKE Node Service Account for ${var.cluster_name}"
}
 
locals {
  node_sa_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer",
  ]
}
 
resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset(local.node_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.gke_node_sa.email}"
}
 
###############################################################################
# 3. GKE CLUSTER — Private, Regional, Hardened
###############################################################################
 
resource "google_container_cluster" "primary" {
  provider = google-beta
 
  name     = var.cluster_name
  location = var.region
 
  remove_default_node_pool = true
  initial_node_count       = 1
 
  network    = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id
 
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }
 
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
 
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
 
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
 
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
 
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
 
  addons_config {
    horizontal_pod_autoscaling { disabled = false }
    http_load_balancing { disabled = false }
    network_policy_config { disabled = false }
    gce_persistent_disk_csi_driver_config { enabled = true }
    gcs_fuse_csi_driver_config { enabled = true }
    dns_cache_config { enabled = true }
  }
 
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
 
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "STORAGE", "POD", "DEPLOYMENT",
      "STATEFULSET", "DAEMONSET", "HPA", "CADVISOR", "KUBELET"]
    managed_prometheus { enabled = true }
  }
 
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T02:00:00Z"
      end_time   = "2024-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }
 
  enable_shielded_nodes = true
 
  release_channel {
    channel = var.release_channel
  }
 
  resource_labels = var.common_labels
 
  lifecycle {
    ignore_changes = [initial_node_count]
  }
}
 
###############################################################################
# 4. NODE POOLS
###############################################################################
 
resource "google_container_node_pool" "system" {
  name       = "system-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
 
  management {
    auto_repair  = true
    auto_upgrade = true
  }
 
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    strategy        = "SURGE"
  }
 
  node_config {
    machine_type    = var.system_node_machine_type
    disk_type       = "pd-ssd"
    disk_size_gb    = 50
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
 
    workload_metadata_config { mode = "GKE_METADATA" }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
 
    taint {
      key    = "node-role"
      value  = "system"
      effect = "NO_SCHEDULE"
    }
 
    labels   = merge(var.common_labels, { "node-pool" = "system" })
    metadata = { disable-legacy-endpoints = "true" }
  }
}
 
resource "google_container_node_pool" "app" {
  name     = "app-pool"
  location = var.region
  cluster  = google_container_cluster.primary.name
 
  autoscaling {
    min_node_count  = var.app_min_nodes
    max_node_count  = var.app_max_nodes
    location_policy = "BALANCED"
  }
 
  management {
    auto_repair  = true
    auto_upgrade = true
  }
 
  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
    strategy        = "SURGE"
  }
 
  node_config {
    machine_type    = var.app_node_machine_type
    disk_type       = "pd-ssd"
    disk_size_gb    = 100
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
 
    workload_metadata_config { mode = "GKE_METADATA" }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
 
    labels   = merge(var.common_labels, { "node-pool" = "app" })
    metadata = { disable-legacy-endpoints = "true" }
  }
}
