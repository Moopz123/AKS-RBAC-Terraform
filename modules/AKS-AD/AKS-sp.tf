  resource "random_password" "MyAKS-passowrd" {
    length  = 32
    special = true
  }

  resource "azuread_application" "MyAKS-QA" {
    name                       = "MyAKS-QA"
    available_to_other_tenants = false
  }

  resource "azuread_service_principal" "MyAKS-QA" {
    application_id = azuread_application.MyAKS-QA.application_id
  }

  resource "azuread_service_principal_password" "MyAKS-QA-SPPass" {
    service_principal_id = azuread_service_principal.MyAKS-QA.id
    value                = random_password.MyAKS-passowrd.result
    end_date_relative    = "17520h" #2y
  }