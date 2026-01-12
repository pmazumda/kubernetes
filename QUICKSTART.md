# Quick Start Guide - K8s Cluster with ArgoCD

This is a quick reference for deploying a single-node Kubernetes cluster with ArgoCD using OpenTofu.

## Prerequisites

- Linux system (Ubuntu/Debian recommended)
- sudo access
- curl, kubectl installed

## Installation

### 1. Install OpenTofu (or Terraform)

```bash
# OpenTofu (recommended)
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method standalone
rm install-opentofu.sh
```

### 2. Deploy the Cluster

```bash
cd tofu-k8s-setup
tofu init
tofu apply
```

Or use the convenience script:
```bash
cd tofu-k8s-setup
./deploy.sh
```

### 3. Access ArgoCD

Get the admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Port-forward to access UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open browser to: http://localhost:8080
- Username: `admin`
- Password: (from above command)

## What's Included

✅ K3s single-node Kubernetes cluster  
✅ Local path storage provisioner  
✅ Traefik ingress controller (built-in)  
✅ ArgoCD GitOps tool  
✅ Example applications  

## Next Steps

1. **Deploy an application**: Check `tofu-k8s-setup/examples/` for sample apps
2. **Connect Git repo**: Configure ArgoCD to sync with your Git repository
3. **Explore ArgoCD**: Create applications through the UI or CLI

## Cleanup

```bash
cd tofu-k8s-setup
tofu destroy
```

## Documentation

Full documentation: [tofu-k8s-setup/README.md](tofu-k8s-setup/README.md)
