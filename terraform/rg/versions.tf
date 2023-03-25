provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "devops-acme"
    storage_account_name = "devopsacmestg2023"
    container_name       = "tfstate"
    key                  = "staging/rg.tfstate"
  }
}