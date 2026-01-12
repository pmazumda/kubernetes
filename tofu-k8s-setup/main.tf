# Install K3s cluster (single node)
resource "null_resource" "install_k3s" {
  provisioner "local-exec" {
    command = <<-EOT
      curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_version} sh -s - \
        --write-kubeconfig-mode 644 \
        --disable traefik \
        --disable servicelb
      
      # Wait for k3s to be ready
      sleep 10
      
      # Copy kubeconfig
      mkdir -p ~/.kube
      sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
      sudo chown $(id -u):$(id -g) ~/.kube/config
      
      # Wait for all system pods to be ready
      kubectl wait --for=condition=ready pod --all -n kube-system --timeout=300s || true
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "/usr/local/bin/k3s-uninstall.sh || true"
  }
}

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  depends_on = [null_resource.install_k3s]

  metadata {
    name = var.argocd_namespace
  }
}

# Install NGINX Ingress Controller (optional, k3s comes with Traefik)
resource "helm_release" "nginx_ingress" {
  count = var.install_nginx_ingress ? 1 : 0

  depends_on = [null_resource.install_k3s]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.9.0"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.hostPort.enabled"
    value = "true"
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.argocd_namespace
  version    = var.argocd_version

  values = [
    yamlencode({
      global = {
        domain = var.argocd_server_host
      }

      server = {
        service = {
          type = "NodePort"
        }

        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          annotations = {
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
            "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
          }
          hosts = [var.argocd_server_host]
        }
      }

      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  timeout = 600
}

# Create storage class for local path provisioner (k3s includes this by default)
resource "kubernetes_storage_class_v1" "local_path" {
  depends_on = [null_resource.install_k3s]

  metadata {
    name = "local-path"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "rancher.io/local-path"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}
