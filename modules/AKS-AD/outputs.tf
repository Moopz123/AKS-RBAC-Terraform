 output "client_id" {
   value = azuread_service_principal.MyAKS-QA.application_id
 }

 output "client_secret" {
   value = random_password.MyAKS-passowrd.result
 }