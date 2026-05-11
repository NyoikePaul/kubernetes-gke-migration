.PHONY: help validate health backup plan apply destroy fmt lint deploy-helm deploy-k8s cluster-connect

help: ## Show this help
@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

validate: ## Validate Terraform + Helm + manifests
@bash tests/validate-manifests.sh

fmt: ## Format all Terraform files
@cd terraform && terraform fmt -recursive && echo "✅ Terraform formatted"

lint: ## Lint the Helm chart
@helm lint helm/gke-platform && echo "✅ Helm lint passed"

health: ## Run cluster health check
@bash scripts/health-check.sh

backup: ## Backup production namespace
@bash scripts/backup.sh production

plan: ## Terraform plan
@cd terraform && terraform plan -var-file=terraform.tfvars

apply: ## Terraform apply
@cd terraform && terraform apply -var-file=terraform.tfvars

destroy: ## Destroy cluster (WARNING)
@cd terraform && terraform apply -var="deletion_protection=false" -var-file=terraform.tfvars
@cd terraform && terraform destroy -var-file=terraform.tfvars

cluster-connect: ## Configure kubectl
@cd terraform && terraform output -raw get_credentials_command | bash

deploy-helm: ## Deploy platform Helm chart
@helm upgrade --install gke-platform ./helm/gke-platform \
--namespace production --create-namespace \
--values helm/gke-platform/values-prod.yaml

deploy-k8s: ## Apply base manifests and security
@kubectl apply -f k8s/base/
@kubectl apply -f security/
@echo "✅ Manifests applied"
