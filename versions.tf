terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "hmp-cassucena-RG"
    storage_account_name = "cassucenaterraformclass"
    container_name       = "cassu-container01"
    key                  = "azure-pipeline/terraform.tfstate"
  }

  }

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


