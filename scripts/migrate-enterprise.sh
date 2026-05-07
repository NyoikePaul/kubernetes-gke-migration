#!/bin/bash

set -e

echo "🚀 Enterprise GKE Migration Script"
echo "=================================="

SOURCE_CLUSTER=${1:-"source-cluster"}
TARGET_CLUSTER=${2:-"target-cluster"}
ZONE=${3:-"us-central1-a"}
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

mkdir -p $BACKUP_DIR

echo "📋 Configuration:"
echo "  Source: $SOURCE_CLUSTER"
echo "  Target: $TARGET_CLUSTER"

# Step 1: Backup source
echo ""
echo "💾 Backing up source cluster..."
gcloud container clusters get-credentials $SOURCE_CLUSTER --zone $ZONE

kubectl get all --all-namespaces -o yaml > $BACKUP_DIR/all-resources.yaml
kubectl get secrets --all-namespaces -o yaml > $BACKUP_DIR/secrets.yaml
kubectl get pvc --all-namespaces -o yaml > $BACKUP_DIR/pvc.yaml

echo "✅ Backup saved to: $BACKUP_DIR"

# Step 2: Connect to target
echo ""
echo "🔗 Connecting to target cluster..."
gcloud container clusters get-credentials $TARGET_CLUSTER --zone $ZONE

# Step 3: Deploy manifests
echo ""
echo "📤 Deploying to target..."
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/rbac/
kubectl apply -f k8s/network-policies/
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
kubectl apply -f k8s/configmaps/

# Step 4: Verify
echo ""
echo "✅ Verifying deployment..."
kubectl get all --all-namespaces

echo ""
echo "✅ Migration completed!"
echo "   Backup: $BACKUP_DIR"
