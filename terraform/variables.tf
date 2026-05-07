variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "gke-cluster"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}

variable "initial_nodes" {
  description = "Initial number of nodes"
  type        = number
  default     = 3
}

variable "min_nodes" {
  description = "Minimum nodes in pool"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum nodes in pool"
  type        = number
  default     = 10
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "n1-standard-2"
}

variable "preemptible" {
  description = "Use preemptible nodes"
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Pods CIDR"
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "Services CIDR"
  type        = string
  default     = "10.8.0.0/20"
}
