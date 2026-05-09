#!/usr/bin/env bash
set -euo pipefail
NODES="${1:-3}" POOL="${2:-app-pool}" REGION="${3:-us-central1}" CLUSTER="${4:-gke-platform}"
gcloud container clusters resize "$CLUSTER" \
  --node-pool "$POOL" --num-nodes "$NODES" \
  --region "$REGION" --project "$(gcloud config get-value project)" --quiet
echo "✅ Scaled $POOL to $NODES nodes/zone"
