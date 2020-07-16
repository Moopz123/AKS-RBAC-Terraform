resource "random_string" "acr-name" {
  length = 8
  number = true
  special = false
  upper = false
  lower = false
}
resource "azurerm_container_registry" "myacr" {
  location = var.location
  name = random_string.acr-name.result
  resource_group_name = var.resource_group
  sku = "standard"
  admin_enabled = false
}