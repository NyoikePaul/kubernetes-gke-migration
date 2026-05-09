# Migration Guide
## Steps
```bash
kubectl get deployments --all-namespaces -o yaml > backup/deployments.yaml
kubectl get services    --all-namespaces -o yaml > backup/services.yaml
cd terraform && terraform apply -var-file=terraform.tfvars
kubectl apply -f backup/
bash scripts/health-check.sh
```
## Rollback
Keep source cluster running 48h. Revert DNS to roll back.
