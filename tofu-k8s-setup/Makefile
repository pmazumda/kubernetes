# Makefile for K3s + ArgoCD cluster management

.PHONY: help init plan apply deploy destroy clean status

# Detect if tofu or terraform is available
TF_CMD := $(shell command -v tofu 2> /dev/null || command -v terraform 2> /dev/null)

help: ## Show this help message
	@echo "K3s + ArgoCD Cluster Management"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform/OpenTofu
	$(TF_CMD) init

plan: ## Show deployment plan
	$(TF_CMD) plan

apply: ## Apply configuration (deploy cluster)
	$(TF_CMD) apply

deploy: ## Deploy using the convenience script
	./deploy.sh

destroy: ## Destroy all resources
	$(TF_CMD) destroy

clean: ## Clean Terraform/OpenTofu files
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f terraform.tfstate*

status: ## Show cluster status
	@echo "=== Cluster Info ==="
	@kubectl cluster-info || echo "Cluster not accessible"
	@echo ""
	@echo "=== All Pods ==="
	@kubectl get pods -A || echo "Cannot get pods"
	@echo ""
	@echo "=== ArgoCD Pods ==="
	@kubectl get pods -n argocd || echo "ArgoCD namespace not found"
	@echo ""
	@echo "=== Storage Classes ==="
	@kubectl get sc || echo "Cannot get storage classes"
	@echo ""
	@echo "=== Services ==="
	@kubectl get svc -A || echo "Cannot get services"

password: ## Get ArgoCD admin password
	@echo "ArgoCD Admin Password:"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
	@echo ""

port-forward: ## Port-forward ArgoCD service
	@echo "Port-forwarding ArgoCD on http://localhost:8080"
	@echo "Username: admin"
	@echo "Password: Run 'make password' to get the password"
	@kubectl port-forward svc/argocd-server -n argocd 8080:443

validate: ## Validate Terraform/OpenTofu configuration
	$(TF_CMD) validate

fmt: ## Format Terraform/OpenTofu files
	$(TF_CMD) fmt -recursive

check: validate fmt ## Run validation and formatting
