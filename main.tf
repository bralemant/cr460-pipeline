provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_group" {
  name     = "MyResourceGroup_CR460"
  location = "eastus2"
}

resource "azurerm_virtual_network" "my_network" {
  name                = "MyVirtualNetwork_CR460"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_group.location
  resource_group_name = azurerm_resource_group.my_group.name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "MySubNet_CR460"
  resource_group_name  = azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.my_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "my_nic" {
  name                = "MyNIC_CR460"
  location            = azurerm_resource_group.my_group.location
  resource_group_name = azurerm_resource_group.my_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.my_subnet
  ]
}

resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = "MyServer-CR460"
  resource_group_name = azurerm_resource_group.my_group.name
  location            = azurerm_resource_group.my_group.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.my_nic.id
  ]

  admin_password                  = "AdminTemp123!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
