   provider "azurerm" {
      version = "=2.0.0"
     features{}
    }

    provider "kubernetes" {
      host = azurerm_kubernetes_cluster.cluster.kube_config[0].host

      client_key = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
      client_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
      cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
    }