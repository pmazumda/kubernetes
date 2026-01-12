#!/bin/bash
# Cleanup script for K3s cluster

set -e

echo "======================================"
echo "K3s + ArgoCD Cleanup Script"
echo "======================================"
echo ""

# Check for tofu or terraform
if command -v tofu >/dev/null 2>&1; then
    TF_CMD="tofu"
elif command -v terraform >/dev/null 2>&1; then
    TF_CMD="terraform"
else
    echo "❌ Neither OpenTofu nor Terraform is installed."
    exit 1
fi

echo "WARNING: This will destroy the entire k3s cluster and all resources!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Destroying resources..."
$TF_CMD destroy -auto-approve

echo ""
echo "Cleanup complete!"
