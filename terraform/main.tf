terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"
    storage_account_name = "tfstategha93842"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc                        = true
  resource_provider_registrations = "none"
}

provider "azuread" {
  use_oidc = true
}

resource "azuread_application" "terraform_rw" {
  display_name = "terraform-rw"
}

resource "azurerm_role_assignment" "terraform_rw_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform_rw.object_id
}

resource "azurerm_role_assignment" "terraform_rw_storage_blob" {
  scope                = var.tfstate_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.terraform_rw.object_id
}

resource "azurerm_role_assignment" "terraform_rw_storage_reader" {
  scope                = var.tfstate_storage_account_id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.terraform_rw.object_id
}

resource "azuread_application_federated_identity_credential" "terraform_rw_prod" {
  application_id = azuread_application.terraform_rw.id
  display_name   = "github-production"
  description    = "GitHub Actions Production Environment"

  audiences = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_org}/${var.github_repo}:environment:${var.production_environment}"
}

resource "azuread_application" "terraform_ro" {
  display_name = "terraform-ro"
}

resource "azuread_service_principal" "terraform_ro" {
  client_id = azuread_application.terraform_ro.client_id
}

resource "azurerm_role_assignment" "terraform_ro_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.terraform_ro.object_id
}

resource "azurerm_role_assignment" "terraform_ro_storage_blob" {
  scope                = var.tfstate_storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_service_principal.terraform_ro.object_id
}

resource "azurerm_role_assignment" "terraform_ro_storage_reader" {
  scope                = var.tfstate_storage_account_id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.terraform_ro.object_id
}

resource "azuread_application_federated_identity_credential" "terraform_ro_pr" {
  application_id = azuread_application.terraform_ro.id
  display_name   = "github-pr"

  audiences = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_org}/${var.github_repo}:pull_request"
}

resource "azuread_application_federated_identity_credential" "terraform_ro_main" {
  application_id = azuread_application.terraform_ro.id
  display_name   = "github-main"

  audiences = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.main_branch}"
}

resource "azuread_service_principal" "terraform_rw" {
  client_id = azuread_application.terraform_rw.client_id
}

resource "azurerm_resource_group" "rg-aks" {
  name     = var.resource_group_name
  location = var.location
}
