resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnets" {
    for_each = var.subnets

    name                 = each.key
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = [each.value.cidr]
}

resource "azurerm_network_security_group" "nsg" {
    for_each = var.subnets
    
    name                = "${var.environment}-${each.key}-nsg"
    location            = var.location
    resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
    for_each = var.subnets

    subnet_id                 = azurerm_subnet.subnets[each.key].id
    network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_network_security_rule" "allow_admin" {
    for_each = var.subnets

    name                        = "Allow-Admin-Access"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = var.allowed_admin_cidr
    destination_address_prefix  = "*"
    network_security_group_name = azurerm_network_security_group.nsg[each.key].name
    resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_http" {
    for_each = {
        for subnet_name, subnet in var.subnets : subnet_name => subnet
        if subnet.allow_http
    }

    name                        = "Allow-HTTP-Access"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    network_security_group_name = azurerm_network_security_group.nsg[each.key].name
    resource_group_name         = var.resource_group_name
}

resource "random_string" "suffix" {
    length  = 6
    upper   = false
    special = false
}

resource "azurerm_storage_account" "diagnostics" {
    count                   = var.create_diagnostics_storage ? 1 : 0
    name                     = "${var.environment}diag${random_string.suffix.result}"
    resource_group_name      = var.resource_group_name
    location                 = var.location
    account_tier             = "Standard"
    account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
}