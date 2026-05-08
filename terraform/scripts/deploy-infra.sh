#!/usr/bin/env bash
set -euo pipefail

# ===================== Colors =====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ===================== Configuration =====================
PROJECT_ID=${PROJECT_ID:-""}
REGION=${REGION:-"us-central1"}
CLUSTER_NAME=${CLUSTER_NAME:-"gke-migration-prod"}
ENVIRONMENT=${ENVIRONMENT:-"production"}

if [[ -z "$PROJECT_ID" ]]; then
  error "PROJECT_ID environment variable is not set!"
fi

TERRAFORM_DIR="terraform"
cd "$TERRAFORM_DIR" || error "Terraform directory not found!"

# ===================== Functions =====================
check_prerequisites() {
  log "Checking prerequisites..."
  command -v terraform >/dev/null 2>&1 || error "Terraform is not installed"
  command -v gcloud >/dev/null 2>&1 || error "gcloud is not installed"
  
  gcloud auth list --filter=status:ACTIVE | grep -q "ACTIVE" || error "Please login with: gcloud auth login"
  log "✅ Prerequisites OK"
}

init_terraform() {
  log "Initializing Terraform..."
  terraform init -upgrade
}

plan() {
  log "Running Terraform Plan..."
  terraform plan \
    -var="project_id=$PROJECT_ID" \
    -var="region=$REGION" \
    -var="cluster_name=$CLUSTER_NAME" \
    -var="environment=$ENVIRONMENT" \
    -out=tfplan
}

apply() {
  log "Applying Terraform configuration..."
  terraform apply -auto-approve tfplan
}

post_deploy() {
  log "Fetching GKE credentials..."
  CLUSTER=$(terraform output -raw cluster_name 2>/dev/null || echo "$CLUSTER_NAME")
  
  gcloud container clusters get-credentials "$CLUSTER" \
    --region="$REGION" \
    --project="$PROJECT_ID"

  log "✅ Cluster is ready!"
  echo "Current context: $(kubectl config current-context 2>/dev/null || echo 'Not set yet')"
}

# ===================== Main =====================
main() {
  log "🚀 Starting GKE Production Deployment"
  echo "Project     : $PROJECT_ID"
  echo "Region      : $REGION"
  echo "Cluster     : $CLUSTER_NAME"
  echo "Environment : $ENVIRONMENT"
  echo "====================================================="

  check_prerequisites
  init_terraform
  plan
  apply
  post_deploy

  log "🎉 Deployment completed successfully!"
}

main "$@"
