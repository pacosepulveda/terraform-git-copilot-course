resource "azurerm_virtual_network" "red" {
  name = "lab-vnet"
  address_space = ["10.0.0.0/16"]
  location = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subred" {
  name = "lab-subnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.red.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "ip_publica" {
  name                      = "lab-public-ip"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  allocation_method         = "Static"
  sku                       = "Standard"     
}

resource "azurerm_network_interface" "nic" {
  name                = "lab-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subred.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_publica.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "lab-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  disable_password_authentication = false
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

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