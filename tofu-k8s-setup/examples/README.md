# ArgoCD Example Applications

This directory contains example Kubernetes manifests that can be deployed via ArgoCD.

## Examples Included

1. **sample-app.yaml** - A simple ArgoCD Application pointing to a demo guestbook
2. **test-storage-pvc.yaml** - Example PersistentVolumeClaim for testing storage
3. **test-nginx-deployment.yaml** - Simple nginx deployment for testing

## Usage

### Deploy via ArgoCD

```bash
# Apply the sample application
kubectl apply -f sample-app.yaml

# Check application status
kubectl get applications -n argocd

# Watch application sync
kubectl get application sample-app -n argocd -w
```

### Deploy directly with kubectl

```bash
# Deploy nginx test
kubectl apply -f test-nginx-deployment.yaml

# Check deployment
kubectl get pods -n default
```

### Test Storage

```bash
# Create PVC
kubectl apply -f test-storage-pvc.yaml

# Check PVC status
kubectl get pvc
```
