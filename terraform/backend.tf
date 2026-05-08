terraform {
  backend "gcs" {
    bucket = "tfstate-${PROJECT_ID}"
    prefix = "gke-migration/terraform/state"
  }
}
