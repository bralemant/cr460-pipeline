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

# 2. Grupo de Recursos
resource "azurerm_resource_group" "my_group" {
  name     = "MyResourceGroup_CR460"
  location = "canadacentral"
}

# 3. Red Virtual
resource "azurerm_virtual_network" "my_network" {
  name                = "MyVirtualNetwork_CR460"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_group.location
  resource_group_name = azurerm_resource_group.my_group.name
}

# 4. Subred
resource "azurerm_subnet" "my_subnet" {
  name                 = "MySubNet_CR460"
  resource_group_name  = azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.my_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

