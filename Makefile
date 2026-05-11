.PHONY: help validate health backup fmt lint

help:
	@echo "Usage: make <target>"

validate:
	@bash tests/validate-manifests.sh

fmt:
	@cd terraform && terraform fmt -recursive

lint:
	@helm lint helm/gke-platform

health:
	@bash scripts/health-check.sh

backup:
	@bash scripts/backup.sh production
