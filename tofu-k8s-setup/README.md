# Single-Node Kubernetes Cluster with ArgoCD using OpenTofu

This directory contains OpenTofu (open-source Terraform) configuration to set up a single-node Kubernetes cluster with ArgoCD and all necessary components.

## Prerequisites

- Linux system (Ubuntu/Debian recommended)
- Root or sudo access
- OpenTofu or Terraform installed
- `curl` and `kubectl` installed

### Install OpenTofu

```bash
# Install OpenTofu (if not already installed)
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method standalone
rm install-opentofu.sh
```

Alternatively, install Terraform:
```bash
# Or use Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## What Gets Deployed

This configuration creates:

1. **K3s Single-Node Cluster** - Lightweight Kubernetes distribution perfect for single-node setups
2. **Storage Provisioner** - Local path provisioner (included with k3s) for persistent volumes
3. **Ingress Controller** - Optional NGINX ingress controller (Traefik is included with k3s by default)
4. **ArgoCD** - GitOps continuous delivery tool
5. **ArgoCD Ingress** - Ingress resource for accessing ArgoCD UI

## Quick Start

### 1. Initialize OpenTofu

```bash
cd tofu-k8s-setup
tofu init
```

Or with Terraform:
```bash
terraform init
```

### 2. Review the Plan

```bash
tofu plan
```

### 3. Apply the Configuration

```bash
tofu apply
```

This will:
- Install k3s on your system
- Configure kubectl access
- Deploy ArgoCD with Helm
- Set up storage and ingress

### 4. Access ArgoCD

After deployment completes, get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Port-forward to access the UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open your browser to: http://localhost:8080
- Username: `admin`
- Password: (from the command above)

## Configuration Options

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
cluster_name          = "my-k3s-cluster"
k3s_version          = "v1.29.0+k3s1"
argocd_namespace     = "argocd"
argocd_version       = "5.51.6"
argocd_server_host   = "argocd.local"
enable_argocd_ingress = true
install_nginx_ingress = false  # Set to true if you want NGINX instead of Traefik
```

### Ingress Options

By default, k3s comes with Traefik ingress controller. You have two options:

1. **Use Traefik (default)**: Set `install_nginx_ingress = false`
   - Traefik is lightweight and included with k3s
   - ArgoCD will automatically use Traefik for ingress

2. **Use NGINX**: Set `install_nginx_ingress = true`
   - Installs NGINX ingress controller
   - K3s will be installed without Traefik
   - ArgoCD will use NGINX for ingress
```

## Verification

Check that everything is running:

```bash
# Check cluster info
kubectl cluster-info

# Check all pods
kubectl get pods -A

# Check ArgoCD specifically
kubectl get pods -n argocd

# Check storage class
kubectl get sc

# Check services
kubectl get svc -A
```

## Components Included

### K3s Features
- Lightweight Kubernetes (single binary)
- Built-in local-path storage provisioner
- Traefik ingress controller (default)
- CoreDNS for service discovery
- Metrics server

### ArgoCD Features
- GitOps deployment automation
- Web UI for application management
- CLI for automation
- SSO integration support
- Multi-cluster management

## Accessing Services

### ArgoCD UI

Option 1: Port Forward
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access at http://localhost:8080
```

Option 2: NodePort
```bash
# Get the NodePort
kubectl get svc argocd-server -n argocd
# Access at http://<node-ip>:<nodeport>
```

Option 3: Ingress (if configured)
```bash
# Add to /etc/hosts
echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts
# Access at http://argocd.local
```

## Useful Commands

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Change ArgoCD admin password (via CLI)
argocd account update-password

# Login to ArgoCD CLI
argocd login localhost:8080

# Create a sample application
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

## Testing Storage

Create a test PVC:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
EOF

# Check PVC status
kubectl get pvc test-pvc
```

## Cleanup

To destroy the cluster and all resources:

```bash
tofu destroy
```

This will:
- Uninstall k3s
- Remove all Kubernetes resources
- Clean up configuration files

**Note:** The k3s uninstall script will be called automatically.

## Troubleshooting

### K3s not starting
```bash
# Check k3s status
sudo systemctl status k3s

# View k3s logs
sudo journalctl -u k3s -f
```

### Pods not starting
```bash
# Check pod status
kubectl get pods -A

# Describe problematic pod
kubectl describe pod <pod-name> -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>
```

### ArgoCD not accessible
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD service
kubectl get svc -n argocd

# Check ingress
kubectl get ingress -n argocd
```

### Storage issues
```bash
# Check storage classes
kubectl get sc

# Check persistent volumes
kubectl get pv

# Check local-path-provisioner
kubectl get pods -n kube-system | grep local-path
```

## Architecture

```
┌─────────────────────────────────────────┐
│         Single Node K3s Cluster         │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐  │
│  │      Control Plane + Worker       │  │
│  │  - API Server                     │  │
│  │  - etcd                           │  │
│  │  - Scheduler                      │  │
│  │  - Controller Manager             │  │
│  │  - Kubelet                        │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │     Ingress Controller            │  │
│  │  - Traefik (default) or NGINX     │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │     Storage Provisioner           │  │
│  │  - local-path-provisioner         │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │          ArgoCD                   │  │
│  │  - Server                         │  │
│  │  - Repo Server                    │  │
│  │  - Application Controller         │  │
│  │  - Redis                          │  │
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

## Next Steps

1. **Configure Git Repository**: Connect ArgoCD to your Git repositories
2. **Create Applications**: Define applications in ArgoCD
3. **Set up RBAC**: Configure role-based access control
4. **Configure SSL/TLS**: Set up certificates for secure access
5. **Backup Strategy**: Implement backup for ArgoCD and cluster state
6. **Monitoring**: Deploy Prometheus/Grafana for monitoring

## Additional Resources

- [K3s Documentation](https://docs.k3s.io/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## License

This configuration is provided as-is for use in the kubernetes repository project.
