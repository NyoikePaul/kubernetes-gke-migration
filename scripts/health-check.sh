#!/usr/bin/env bash
set -euo pipefail

echo "=== GKE Platform Health Check ==="

echo "-- Nodes --"
kubectl get nodes -o wide

echo "-- System Pods --"
kubectl get pods -n kube-system --field-selector=status.phase!=Running 2>/dev/null \
  && echo "All system pods running." || echo "WARNING: some system pods not running."

echo "-- All Namespaces Pod Status --"
kubectl get pods --all-namespaces --field-selector=status.phase!=Running 2>/dev/null \
  || echo "All pods healthy."

echo "-- HPA Status --"
kubectl get hpa --all-namespaces 2>/dev/null || echo "No HPAs found."

echo "=== Health Check Complete ==="
