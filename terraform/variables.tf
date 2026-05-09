variable "project_id" {
  type        = string
  description = "GCP Project ID where the cluster will be created."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for the regional cluster."
}

variable "cluster_name" {
  type        = string
  default     = "gke-platform"
  description = "Base name used for the cluster and all derived resources."
}

variable "release_channel" {
  type        = string
  default     = "REGULAR"
  description = "GKE release channel: RAPID | REGULAR | STABLE."
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE."
  }
}

variable "node_cidr" {
  type    = string
  default = "10.0.0.0/20"
}

variable "pod_cidr" {
  type    = string
  default = "10.4.0.0/14"
}

variable "svc_cidr" {
  type    = string
  default = "10.0.32.0/20"
}

variable "master_ipv4_cidr" {
  type    = string
  default = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [{ cidr_block = "0.0.0.0/0", display_name = "all (tighten in production!)" }]
}

variable "system_node_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "app_node_machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "app_min_nodes" {
  type    = number
  default = 1
}

variable "app_max_nodes" {
  type    = number
  default = 5
}

variable "common_labels" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    environment = "production"
    project     = "gke-migration"
  }
}
# validated 2026-05-09
