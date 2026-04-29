resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.network_config.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# En este laboratorio solo usamos la primera subnet definida
resource "azurerm_subnet" "subnet1" {
    name                 = "${var.project_name}-subnet1"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = [var.network_config.public_subnets[0]]
}

resource "azurerm_network_security_group" "app" {
    name                = "${var.project_name}-nsg"
    location            = var.location
    resource_group_name = var.resource_group_name

    security_rule {
        name                       = "AllowSSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
    subnet_id                 = azurerm_subnet.subnet1.id
    network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_public_ip" "public_ip" {
    name                = "${var.project_name}-pip"
    location            = var.location
    resource_group_name = var.resource_group_name
    allocation_method   = "Static"
  sku                   = "Standard"
}

resource "azurerm_network_interface" "nic" {
    name                = "${var.project_name}-nic"
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip.id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                = "${var.project_name}-vm"
    location            = var.location
    resource_group_name = var.resource_group_name
    size                = var.vm_size[var.environment]
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
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-LTS"
        version   = "latest"
    }
}