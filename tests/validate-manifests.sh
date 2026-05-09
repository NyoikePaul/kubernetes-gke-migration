#!/usr/bin/env bash
set -euo pipefail
echo "=== Validating ==="
helm lint helm/gke-platform && echo "✅ Helm valid"
cd terraform
terraform fmt -check -recursive && echo "✅ Terraform formatted"
terraform validate && echo "✅ Terraform valid"
cd ..
echo "=== Done ==="
