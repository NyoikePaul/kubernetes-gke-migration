#!/bin/bash
# A script to trigger a migration backup using Velero
echo "📦 Starting Velero migration backup..."

# Check if Velero CLI is installed
if ! command -v velero &> /dev/null; then
    echo "❌ Velero CLI not found. Please install it to run migrations."
    exit 1
fi

# Trigger backup for the production namespace
velero backup create gke-migration-$(date +%Y%m%d%H%M) \
    --include-namespaces default \
    --wait

echo "✅ Backup complete. Ready for migration to target cluster."
