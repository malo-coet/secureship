# Values Terraform prints after `apply` — you'll need these for the next steps.

output "resource_group" {
  description = "Resource group name — used to fetch cluster credentials."
  value       = azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  description = "AKS cluster name — used by `az aks get-credentials`."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  description = "ACR hostname, e.g. secureshipacrxxxxxx.azurecr.io — this goes in your image tag."
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "ACR short name — used by `az acr build` / `az acr login`."
  value       = azurerm_container_registry.acr.name
}
