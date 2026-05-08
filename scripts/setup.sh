#!/bin/bash
# WSL-Friendly Setup Script

echo "=== Kubernetes GKE Migration Setup (WSL Safe) ==="

# Create directories
for dir in terraform helm k8s scripts docs; do
    if [ ! -d "$dir" ]; then
        echo "Creating $dir directory..."
        mkdir -p "$dir"
    fi
done

# Terraform setup
if [ -d "terraform" ]; then
    echo "→ Setting up Terraform..."
    cd terraform || { echo "Failed to enter terraform directory"; exit 1; }
    
    if [ ! -f "backend.tf" ]; then
        PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "your-project-id")
        cat > backend.tf <<EOF2
terraform {
  backend "gcs" {
    bucket = "tfstate-\${PROJECT_ID}"
    prefix = "gke-migration/terraform/state"
  }
}
EOF2
        echo "✅ backend.tf created (update PROJECT_ID if needed)"
    fi

    terraform init -upgrade || echo "⚠️ Terraform init failed"
    cd ..
else
    echo "⚠️ terraform/ directory not found"
fi

echo ""
echo "✅ Setup completed!"
echo "Next steps:"
echo "   1. Install Terraform (see below)"
echo "   2. ./scripts/setup.sh"
echo ""
