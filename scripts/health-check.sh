#!/bin/bash
echo "🚀 Starting Pre-Migration Health Check..."

# Check if kubectl can connect
kubectl cluster-info || { echo "❌ Cluster unreachable"; exit 1; }

# Check Node Status
READY_NODES=$(kubectl get nodes | grep -c " Ready")
echo "✅ Nodes Ready: $READY_NODES"

# Check for failing pods
FAILED_PODS=$(kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded | wc -l)
if [ "$FAILED_PODS" -gt 1 ]; then
    echo "⚠️ Warning: $FAILED_PODS pods are not running."
else
    echo "✅ All system pods healthy."
fi
