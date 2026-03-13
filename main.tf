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


# 5. Creamos la "Puerta" de red (Tarjeta de Interfaz de Red - NIC)
resource "azurerm_network_interface" "mi_nic" {
  name                = "Virtual-NIC_CR460"
  location            = azurerm_resource_group.mi_grupo.location
  resource_group_name = azurerm_resource_group.mi_grupo.name

  ip_configuration {
    name                          = "config_interna"
    subnet_id                     = azurerm_subnet.mi_subred.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 6. Construimos la "Casa" (La Máquina Virtual de Linux)
resource "azurerm_linux_virtual_machine" "mi_vm" {
  name                = "MyServer-CR460"
  resource_group_name = azurerm_resource_group.mi_grupo.name
  location            = azurerm_resource_group.mi_grupo.location
  size                = "Standard_B1s" # Un tamaño de computadora pequeño y económico
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.mi_nic.id, # Aquí le conectamos la "puerta" que creamos arriba
  ]

  # IMPORTANTE: Definimos la contraseña de acceso.
  admin_password                  = "Admin*123!" 
  disable_password_authentication = false

  # Configuramos el "Disco Duro" de la computadora
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Le decimos que instale Linux Ubuntu
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
