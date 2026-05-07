# Deployment Guide

## Using Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Using Helm

```bash
helm install platform ./helm/gke-platform \
  --namespace production \
  --values values-prod.yaml
```

## Using kubectl

```bash
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
kubectl apply -f k8s/configmaps/
```

## Verification

```bash
kubectl get all -n production
kubectl get pods -o wide
kubectl logs -f deployment/production-app -n production
```
