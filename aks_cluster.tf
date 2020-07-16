  resource "azurerm_resource_group" "aks" {
    name     = var.resource_group
    location = var.location
  }

  module "aks-network" {
    source = "./modules/AKS-Network"
    subnet_name         = var.subnet_name
    vnet_name           = var.vnet_name
    resource_group_name = azurerm_resource_group.aks.name
    subnet_cidr         = var.subnet_cidr
    location            = var.location
    address_space       = var.address_space
    network_security_group_name = var.network_security_group_name
  }

  module "azure-ad" {
    source = "./modules/AKS-AD"
    cluster_name = var.cluster_name
  }

  module "aks-cluster" {
    source = "./modules/AKS-Cluster"
    cluster_name             = var.cluster_name
    location                 = var.location
    os_type                  = var.os_type
    dns_prefix               = var.dns_prefix
    resource_group           = azurerm_resource_group.aks.name
    #  kubernetes_version       = var.kubernetes_version
    node_count               = var.node_count
    os_disk_size_gb          = "40"
    max_pods                 = "110"
    vm_size                  = var.vm_size
    vnet_subnet_id           = module.aks-network.aks_subnet_id
    service_principal_client_id     = module.azure-ad.client_id
    service_principal_client_secret = module.azure-ad.client_secret
  }