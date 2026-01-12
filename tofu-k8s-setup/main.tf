# Install K3s cluster (single node)
resource "null_resource" "install_k3s" {
  provisioner "local-exec" {
    command = <<-EOT
      # Install k3s with or without traefik based on ingress choice
      if [ "${var.install_nginx_ingress}" = "true" ]; then
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_version} sh -s - \
          --write-kubeconfig-mode 644 \
          --disable traefik \
          --disable servicelb
      else
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_version} sh -s - \
          --write-kubeconfig-mode 644 \
          --disable servicelb
      fi
      
      # Copy kubeconfig
      mkdir -p ~/.kube
      sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
      sudo chown $(id -u):$(id -g) ~/.kube/config
      
      # Wait for all system pods to be ready
      kubectl wait --for=condition=ready pod --all -n kube-system --timeout=300s
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
  version    = var.nginx_ingress_version

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
  depends_on = [
    kubernetes_namespace.argocd
  ]

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
          enabled          = var.enable_argocd_ingress
          ingressClassName = var.install_nginx_ingress ? "nginx" : "traefik"
          annotations = var.install_nginx_ingress ? {
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
            "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
            } : {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
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

# Note: K3s includes local-path storage class by default
# No need to create it explicitly
