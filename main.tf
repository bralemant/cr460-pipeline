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
  location = "eastus"
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


# 5. Creamos la "Puerta" de red (Tarjeta de Interfaz de Red - NIC)
resource "azurerm_network_interface" "my_nic" {
  name                = "MyNIC_CR460"
  location            = azurerm_resource_group.my_group.location
  resource_group_name = azurerm_resource_group.my_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 6. Construimos la "Casa" (La Máquina Virtual de Linux)
resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = "MyServer-CR460"
  resource_group_name = azurerm_resource_group.my_group.name
  location            = azurerm_resource_group.my_group.location
  size                = "Standard_DS1_v2"  # por ejemplo, en lugar de Standard_B1s
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.my_nic.id,
  ]

  admin_password                  = "Admin*123!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

