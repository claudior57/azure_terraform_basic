provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "devops-acme"
    storage_account_name = "devopsacmestg2023"
    container_name       = "tfstate"
    key                  = "staging/bastion.tfstate"
  }
}

data "terraform_remote_state" "rg" {
  backend = "azurerm"
  config = {
    resource_group_name  = "devops-acme"
    storage_account_name = "devopsacmestg2023"
    container_name       = "tfstate"
    key                  = "staging/rg.tfstate"
  }
}

data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = {
    resource_group_name  = "devops-acme"
    storage_account_name = "devopsacmestg2023"
    container_name       = "tfstate"
    key                  = "staging/vnet.tfstate"
  }
}