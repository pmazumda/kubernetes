#!/bin/bash
# Deployment script for single-node Kubernetes cluster with ArgoCD

set -e

echo "======================================"
echo "K3s + ArgoCD Deployment Script"
echo "======================================"
echo ""

# Check if running as root for k3s installation
if [ "$EUID" -eq 0 ]; then 
   echo "Please do not run this script as root."
   echo "The script will use sudo when needed."
   exit 1
fi

# Check prerequisites
echo "Checking prerequisites..."

command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Aborting." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting." >&2; exit 1; }

# Check for tofu or terraform
if command -v tofu >/dev/null 2>&1; then
    TF_CMD="tofu"
    echo "✓ OpenTofu found"
elif command -v terraform >/dev/null 2>&1; then
    TF_CMD="terraform"
    echo "✓ Terraform found"
else
    echo "❌ Neither OpenTofu nor Terraform is installed."
    echo ""
    echo "Please install one of them:"
    echo "  OpenTofu: https://opentofu.org/docs/intro/install/"
    echo "  Terraform: https://www.terraform.io/downloads"
    exit 1
fi

echo ""
echo "Prerequisites check passed!"
echo ""

# Initialize
echo "Initializing $TF_CMD..."
$TF_CMD init

echo ""
echo "Planning deployment..."
$TF_CMD plan -out=tfplan

echo ""
read -p "Do you want to apply this plan? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "Applying configuration..."
$TF_CMD apply tfplan

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo ""
echo "Getting ArgoCD initial password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)

echo ""
echo "======================================"
echo "ArgoCD Access Information"
echo "======================================"
echo ""
echo "To access ArgoCD, run:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open: http://localhost:8080"
echo ""
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "======================================"
echo ""

# Show cluster info
echo "Cluster information:"
kubectl cluster-info

echo ""
echo "All pods:"
kubectl get pods -A

echo ""
echo "Storage classes:"
kubectl get sc

echo ""
echo "Setup complete! Happy GitOps-ing! 🚀"
