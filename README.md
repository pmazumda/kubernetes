# kubernetes
This repository contains  few projects I have been  working on

## Projects

### OpenTofu K8s Setup (`tofu-k8s-setup/`)
Infrastructure as Code using OpenTofu to deploy a single-node Kubernetes cluster with ArgoCD and all necessary components (storage, ingress, etc.). See [tofu-k8s-setup/README.md](tofu-k8s-setup/README.md) for detailed documentation.

**Quick Start:**
```bash
cd tofu-k8s-setup
tofu init
tofu apply
```

### ArgoCD App Configs (`argocd-app-configs/`)
ArgoCD application configurations and patches for GitOps deployments.

### Monitoring Stack
- **Prometheus** - Metrics collection
- **Grafana** - Metrics visualization  
- **cAdvisor** - Container metrics
- **Kube State Metrics** - Kubernetes object metrics
- **Node Exporter** - Node-level metrics

### Helm Charts (`helm-charts/`)
Custom Helm charts for various applications.
