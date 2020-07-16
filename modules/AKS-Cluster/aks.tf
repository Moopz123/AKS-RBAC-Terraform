
 resource "null_resource" "delay_before_consent" {
  provisioner "local-exec" {
    command = "waitfor Something /t 60 2>NUL || type nul>nul"
  }
  depends_on = [
    azuread_service_principal.aks-aad-srv,
    azuread_service_principal.aks-aad-client
  ]
}

# Give admin consent - SP/az login user must be AAD admin

  resource "null_resource" "grant_srv_admin_constent" {
    provisioner "local-exec" {
      command = "az ad app permission admin-consent --id ${azuread_application.aks-aad-srv.application_id}"
    }
    depends_on = [
      null_resource.delay_before_consent
    ]
  }
  resource "null_resource" "grant_client_admin_constent" {
    provisioner "local-exec" {
      command = "az ad app permission admin-consent --id ${azuread_application.aks-aad-client.application_id}"
    }
    depends_on = [
      null_resource.delay_before_consent
    ]
  }

  # Again, wait for a few seconds...

  resource "null_resource" "delay" {
    provisioner "local-exec" {
      command = "waitfor Something /t 60 2>NUL || type nul>nul"
    }
    depends_on = [
      null_resource.grant_srv_admin_constent,
      null_resource.grant_client_admin_constent
    ]
  }

data "azurerm_subscription" "current" {}

  resource "azurerm_kubernetes_cluster" "cluster" {
    name = var.cluster_name
    location = var.location
    resource_group_name = var.resource_group
    dns_prefix = var.dns_prefix


    default_node_pool {
      name       = var.agent_pool_name
      node_count = var.node_count
      vm_size    = var.vm_size
      vnet_subnet_id = var.vnet_subnet_id
      os_disk_size_gb = var.os_disk_size_gb
      type = var.agent_pool_type
    }

    service_principal {
      client_id     = var.service_principal_client_id
      client_secret = var.service_principal_client_secret
    }
   
    network_profile {
      network_plugin = var.network_plugin
      docker_bridge_cidr = var.docker_network_cidr
      network_policy = var.network_policy
      dns_service_ip = var.dns_service_ip
      service_cidr = var.service_cidr
    }

    role_based_access_control {
      azure_active_directory {
        client_app_id = azuread_application.aks-aad-client.application_id
        server_app_id = azuread_application.aks-aad-srv.application_id
        server_app_secret = random_password.aks-aad-srv.result
        tenant_id = data.azurerm_subscription.current.tenant_id
      }
      enabled = true
    }
    depends_on = [
      azuread_application.aks-aad-client
     # azuread_service_principal_password.aks-aad-client-password
  ]

  }

  resource "kubernetes_cluster_role_binding" "cluster-admin" {
    connection {
      host = azurerm_kubernetes_cluster.cluster.kube_config[0].host
    }
    metadata {
      name = "${var.cluster_name}-admin"
    }
    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind = "ClusterRole"
      name = "cluster-admin"
    }
    subject {
      kind = "Group"
      name = azuread_group.aks-aad-clusteradmins.id
      namespace = "kube-sytem"
    }
  }
