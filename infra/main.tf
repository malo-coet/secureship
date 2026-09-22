###############################################################################
# SecureShip — Azure infrastructure as code (Terraform)
#
# What this creates:
#   1. A Resource Group        — a container that holds everything (easy teardown)
#   2. An Azure Container Registry (ACR) — private store for our Docker image
#   3. An AKS cluster          — the managed Kubernetes that runs our containers
#   4. A role assignment       — lets AKS pull images from ACR *by identity*,
#                                with no password. This is the secure way.
#
# Teardown = `terraform destroy` deletes all 4 in one shot → no surprise cost.
###############################################################################

terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id is picked up automatically from `az login`.
}

# ACR names must be globally unique and lowercase-alphanumeric. We suffix a
# short random string so you never clash with someone else's registry.
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# 1) Resource Group -----------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# 2) Azure Container Registry -------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic" # cheapest tier, fine for this project
  admin_enabled       = false   # security: no admin username/password, we use identity
}

# 3) AKS cluster --------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-aks"
  sku_tier            = "Free" # free control plane — you only pay for the nodes

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_size # Standard_B2s = small & cheap
  }

  # The cluster gets its own managed identity (an Azure-managed credential we
  # never see or handle). We grant *that* identity the right to pull from ACR.
  identity {
    type = "SystemAssigned"
  }
}

# 4) Let AKS pull from ACR by identity (no password) --------------------------
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
