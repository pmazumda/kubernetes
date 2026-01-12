output "cluster_info" {
  description = "Kubernetes cluster information"
  value = {
    name        = var.cluster_name
    k3s_version = var.k3s_version
    kubeconfig  = var.kubeconfig_path
  }
}

output "argocd_info" {
  description = "ArgoCD installation information"
  value = {
    namespace   = var.argocd_namespace
    server_host = var.argocd_server_host
    version     = var.argocd_version
  }
}

output "argocd_initial_password" {
  description = "Command to get ArgoCD initial admin password"
  value       = "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  sensitive   = false
}

output "argocd_access_instructions" {
  description = "Instructions to access ArgoCD"
  value       = <<-EOT
    ArgoCD has been installed successfully!
    
    1. Get the initial admin password:
       kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    
    2. Port-forward to access ArgoCD UI:
       kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:443
       
    3. Access ArgoCD at: http://localhost:8080
       Username: admin
       Password: (from step 1)
    
    4. Or access via NodePort:
       kubectl get svc argocd-server -n ${var.argocd_namespace}
  EOT
}

output "useful_commands" {
  description = "Useful kubectl commands"
  value       = <<-EOT
    # Check cluster status
    kubectl cluster-info
    
    # Check all pods
    kubectl get pods -A
    
    # Check ArgoCD pods
    kubectl get pods -n ${var.argocd_namespace}
    
    # Check storage classes
    kubectl get sc
    
    # Check ingress controllers
    kubectl get pods -n ingress-nginx
    
    # Access ArgoCD UI
    kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:443
  EOT
}
