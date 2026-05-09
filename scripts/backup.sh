#!/usr/bin/env bash
set -euo pipefail
NS="${1:-production}"
DIR="backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DIR"
kubectl get deployments -n "$NS" -o yaml > "$DIR/deployments.yaml"
kubectl get services    -n "$NS" -o yaml > "$DIR/services.yaml"
kubectl get configmaps  -n "$NS" -o yaml > "$DIR/configmaps.yaml"
echo "✅ Backup saved to $DIR"
