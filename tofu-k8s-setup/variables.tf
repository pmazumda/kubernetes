variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k3s-local"
}

variable "k3s_version" {
  description = "K3s version to install"
  type        = string
  default     = "v1.28.5+k3s1"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD installation"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "argocd_server_host" {
  description = "Hostname for ArgoCD server ingress"
  type        = string
  default     = "argocd.local"
}

variable "install_nginx_ingress" {
  description = "Whether to install NGINX ingress controller (set to false if using Traefik from k3s)"
  type        = bool
  default     = false
}
