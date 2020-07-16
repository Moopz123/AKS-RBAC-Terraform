  resource "azuread_group" "aks-aad-clusteradmins" {
    name = "${var.cluster_name}-clusteradmin"
  }