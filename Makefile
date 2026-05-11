.PHONY: help validate health backup plan apply destroy fmt lint
 
help: ## Show this help
@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
 
validate: ## Validate all Terraform + Helm + manifests
@bash tests/validate-manifests.sh
 
fmt: ## Format all Terraform files
@cd terraform && terraform fmt -recursive && echo "✅ Terraform formatted"
 
lint: ## Lint the Helm chart
@helm lint helm/gke-platform && echo "✅ Helm lint passed"
 
health: ## Run cluster health check
@bash scripts/health-check.sh
 
backup: ## Backup production namespace
@bash scripts/backup.sh production
 
plan: ## Terraform plan (requires terraform.tfvars)
@cd terraform && terraform plan -var-file=terraform.tfvars
 
apply: ## Terraform apply (requires terraform.tfvars)
@cd terraform && terraform apply -var-file=terraform.tfvars
 
destroy: ## Terraform destroy — WARNING: destroys cluster
@cd terraform && terraform apply -var="deletion_protection=false" -var-file=terraform.tfvars
@cd terraform && terraform destroy -var-file=terraform.tfvars
 
cluster-connect: ## Configure kubectl for the cluster
@cd terraform && terraform output get_credentials_command | bash
 
deploy-helm: ## Deploy the platform Helm chart
@helm upgrade --install gke-platform ./helm/gke-platform \
--namespace production --create-namespace \
--values helm/gke-platform/values-prod.yaml
 
deploy-k8s: ## Apply base k8s manifests and security configs
@kubectl apply -f k8s/base/
@kubectl apply -f security/
@echo "✅ Manifests applied"
