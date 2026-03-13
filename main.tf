variable "ARM_CLIENT_SECRET" {
  type = string
}

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}

# 1. Le decimos a Terraform que use Microsoft Azure
provider "azurerm" {
  features {}
}

# 2. Le damos las instrucciones para crear la "Caja" o Grupo de Recursos
resource "azurerm_resource_group" "my_group" {
  name     = "MyResourceGroup_CR460"
  location = "canadacentral"
}


