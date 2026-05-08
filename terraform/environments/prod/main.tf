terraform {
  # Comment out the GCS backend for now
  # backend "gcs" {
  #   bucket = "nyoike-paul-tfstate"
  #   prefix = "terraform/state"
  # }

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}
