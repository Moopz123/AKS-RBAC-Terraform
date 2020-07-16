 provider "azurerm" {
   version = "=2.0.0"
   features{}

  }

  provider "kubernetes" {
      host = module.aks-cluster.k8shostname

      client_key             = base64decode(module.aks-cluster.client_key)
      client_certificate     = base64decode(module.aks-cluster.client_certificate)
      cluster_ca_certificate = base64decode(module.aks-cluster.cluster_ca_certificate)
    }
